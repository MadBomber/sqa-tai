# frozen_string_literal: true

# Monkey patch for ta_lib_ffi 0.3.0 to fix multi-array parameter bug
#
# This patch fixes a critical bug in ta_lib_ffi 0.3.0 where functions requiring
# multiple array parameters (high, low, close) fail with NoMethodError.
#
# Affected functions:
# - All volatility indicators (ATR, NATR, SAR, TRANGE)
# - All momentum indicators requiring OHLC (CCI, WILLR, ADX, STOCH)
# - All volume indicators (OBV, AD, ADOSC)
# - All candlestick pattern recognition functions (60+ patterns)
#
# This patch can be removed once ta_lib_ffi fixes the upstream bug.

module TALibFFI
  class << self
    # Store original method to call it for non-price parameters
    alias original_setup_input_parameters setup_input_parameters

    # Fixed version that properly handles multi-array Price inputs
    #
    # The original code assumes a 1-to-1 mapping between input_arrays and function
    # parameters, but TA_Input_Price parameters can consume multiple arrays.
    #
    # This fix:
    # 1. Tracks position in input_arrays with array_index
    # 2. For each function parameter, checks its type
    # 3. For TA_Input_Price, determines how many arrays are needed from flags
    # 4. Bundles those arrays together: [[high], [low], [close]]
    # 5. Passes the bundle to setup_price_inputs
    # 6. Advances array_index by the number of arrays consumed
    def setup_input_parameters(params_ptr, input_arrays, func_name)
      func_info = function_info_map[func_name]
      array_index = 0  # Track position in input_arrays

      func_info[:inputs].each_with_index do |input_info, param_index|
        array_index = assign_input_parameter(
          params_ptr, input_arrays, func_name, input_info, param_index, array_index
        )
      end

      verify_all_arrays_consumed(func_name, array_index, input_arrays)
    end

    # Dispatches a single function-parameter to its type-specific handler and
    # returns the advanced array_index.
    def assign_input_parameter(params_ptr, input_arrays, func_name, input_info, param_index, array_index)
      case input_info["type"]
      when TA_PARAM_TYPE[:TA_Input_Price]
        assign_price_input(params_ptr, input_arrays, func_name, input_info, param_index, array_index)
      when TA_PARAM_TYPE[:TA_Input_Real], TA_PARAM_TYPE[:TA_Input_Integer]
        assign_single_array_input(params_ptr, input_arrays, func_name, input_info, param_index, array_index)
      else
        # Unknown type - should not happen, but handle gracefully
        raise ArgumentError, "Unknown input type #{input_info['type']} for function #{func_name}"
      end
    end

    # Price inputs consume multiple arrays based on required flags
    def assign_price_input(params_ptr, input_arrays, func_name, input_info, param_index, array_index)
      required_flags = extract_flags(input_info["flags"], :TA_InputFlags)
      num_arrays = required_flags.length

      # Collect the next num_arrays from input_arrays
      if array_index + num_arrays > input_arrays.length
        raise ArgumentError, "Function #{func_name} requires #{num_arrays} price arrays " \
                             "(#{required_flags.join(', ')}), but only #{input_arrays.length - array_index} " \
                             "provided at position #{array_index}"
      end

      price_arrays = input_arrays[array_index, num_arrays]

      # Pass the bundled arrays to set_input_parameter
      ret_code = set_input_parameter(params_ptr, param_index, price_arrays, input_info)
      check_ta_return_code(ret_code)

      array_index + num_arrays  # Advance by number of arrays consumed
    end

    # Single array inputs (Real or Integer)
    def assign_single_array_input(params_ptr, input_arrays, func_name, input_info, param_index, array_index)
      if array_index >= input_arrays.length
        raise ArgumentError, "Not enough input arrays for function #{func_name} " \
                             "(expected array at index #{array_index}, but only #{input_arrays.length} provided)"
      end

      ret_code = set_input_parameter(params_ptr, param_index, input_arrays[array_index], input_info)
      check_ta_return_code(ret_code)

      array_index + 1  # Advance by one
    end

    # Verify all arrays were consumed
    def verify_all_arrays_consumed(func_name, array_index, input_arrays)
      return if array_index == input_arrays.length

      raise ArgumentError, "Function #{func_name} expected #{array_index} input arrays " \
                           "but received #{input_arrays.length}"
    end

    # Store original method
    alias original_setup_price_inputs setup_price_inputs

    # Fixed version that handles bundled price arrays correctly
    #
    # After the setup_input_parameters fix, price_data is now guaranteed to be
    # an array of arrays: [[high_array], [low_array], [close_array]]
    def setup_price_inputs(params_ptr, index, price_data, flags)
      required_flags = extract_flags(flags, :TA_InputFlags)
      data_pointers = Array.new(6) { Fiddle::Pointer.malloc(0) }

      # price_data is now an array of arrays: [[high], [low], [close]]
      # Each element corresponds to one required flag
      required_flags.each_with_index do |flag, i|
        data_pointers[flag_index_for(flag)] = pointer_for_price_array(price_data, flag, i)
      end

      TA_SetInputParamPricePtr(params_ptr, index, *data_pointers)
    end

    def flag_index_for(flag)
      TA_FLAGS[:TA_InputFlags].keys.index(flag)
    end

    # Validates and converts the price array at position i (for the given flag)
    # into an FFI double-array pointer.
    def pointer_for_price_array(price_data, flag, i)
      array = price_data[i]

      raise ArgumentError, "Missing price array for flag #{flag} at index #{i}" if array.nil?

      unless array.is_a?(Array)
        raise ArgumentError, "Expected array for flag #{flag} at index #{i}, got #{array.class}"
      end

      prepare_double_array(array)
    end

    # Store original method
    alias original_calculate_results calculate_results

    # Fixed version that correctly determines input_size for Price inputs
    #
    # The original code expects input_arrays[0][0].length for Price inputs,
    # which assumes format [[high], [low], [close]]. Our fix passes [high, low, close],
    # so we need to adjust this check.
    def calculate_results(params_ptr, input_arrays, func_name)
      # Input size is the length of the first input array, regardless of
      # whether it holds Price inputs ([high, low, close]) or other inputs.
      input_size = input_arrays[0].length

      out_begin = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT)
      out_size = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT)
      output_arrays = setup_output_buffers(params_ptr, input_size, func_name)

      begin
        run_ta_call_func(params_ptr, input_size, out_begin, out_size)
        actual_size = out_size[0, Fiddle::SIZEOF_INT].unpack1("l")
        format_output_results(output_arrays, actual_size, func_name)
      ensure
        out_begin.free
        out_size.free
      end
    end

    def run_ta_call_func(params_ptr, input_size, out_begin, out_size)
      ret_code = TA_CallFunc(params_ptr, 0, input_size - 1, out_begin, out_size)
      check_ta_return_code(ret_code)
    end
  end
end
