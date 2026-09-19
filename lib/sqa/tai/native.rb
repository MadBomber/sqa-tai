# frozen_string_literal: true

require "fiddle"
require "fiddle/import"

module SQA
  module TAI
    # Direct Fiddle binding against the installed TA-Lib C library's
    # abstract interface. Replaces the (now dropped) `ta_lib_ffi` gem,
    # which was unmaintained and carried a struct-layout bug that made
    # it incompatible with current TA-Lib builds (see TA_FuncInfo below).
    #
    # Uses TA-Lib's own introspection API (TA_GetFuncInfo /
    # TA_Get{Input,OptInput,Output}ParameterInfo) to discover each
    # function's signature at runtime instead of hand-writing ~158
    # bindings, then dispatches generically through method_missing.
    #
    # rubocop:disable Metrics/ModuleLength -- one cohesive FFI binding:
    # struct/const declarations plus the introspection + marshaling logic
    # that reads them. Splitting it would separate code that must stay in
    # lockstep with the installed TA-Lib header.
    #
    # :reek:TooManyConstants -- structs, type-tag maps, and value-object
    # classes for TA-Lib's abstract interface; inherent to binding a C
    # library's struct/enum surface, already trimmed to the minimum (see
    # the comment above TA_SUCCESS/TA_FUNC_NOT_FOUND for how the 17
    # TA_RetCode constants were folded away).
    module Native
      extend Fiddle::Importer

      lib_path =
        case RUBY_PLATFORM
        when /darwin/
          brew_prefix = `brew --prefix`.chomp
          "#{brew_prefix}/lib/libta-lib.dylib"
        when /linux/
          "libta-lib.so"
        when /cygwin|mswin|mingw|bccwin|wince|emx/
          "C:/Program Files/TA-Lib/bin/ta-lib.dll"
        else
          raise "Unsupported platform: #{RUBY_PLATFORM}"
        end

      dlload lib_path

      class TALibError < StandardError; end

      # Only TA_SUCCESS and TA_FUNC_NOT_FOUND are compared against directly
      # elsewhere in this file; every other TA_RetCode is only ever used to
      # look up its message below, so those live solely as TA_ERROR_MESSAGES
      # keys instead of 17 more standalone constants.
      TA_SUCCESS        = 0
      TA_FUNC_NOT_FOUND = 5

      typealias "TA_Real", "double"
      typealias "TA_Integer", "int"
      typealias "TA_FuncFlags", "int"
      typealias "TA_InputParameterType", "int"
      typealias "TA_InputFlags", "int"
      typealias "TA_OptInputParameterType", "int"
      typealias "TA_OptInputFlags", "int"
      typealias "TA_OutputParameterType", "int"
      typealias "TA_OutputFlags", "int"

      # Matches $(brew --prefix)/include/ta-lib/ta_abstract.h's TA_FuncInfo.
      #
      # The installed TA-Lib C library (Homebrew's 0.8.x community fork)
      # does NOT have a `camelCaseName` field here, even though older
      # TA-Lib builds (and the abandoned ta_lib_ffi gem this replaces)
      # assumed one. Keeping that phantom field misaligns every field
      # after `hint` (flags/nbInput/nbOptInput/nbOutput/handle), so
      # introspection reads garbage counts and spins forever allocating
      # memory. Verify against the installed header before ever changing
      # this struct.
      TA_FuncInfo = struct [
        "const char *name",
        "const char *group",
        "const char *hint",
        "TA_FuncFlags flags",
        "unsigned int nbInput",
        "unsigned int nbOptInput",
        "unsigned int nbOutput",
        "const void *handle"
      ]

      TA_InputParameterInfo = struct [
        "TA_InputParameterType type",
        "const char *paramName",
        "TA_InputFlags flags"
      ]

      TA_OptInputParameterInfo = struct [
        "TA_OptInputParameterType type",
        "const char *paramName",
        "TA_OptInputFlags flags",
        "const char *displayName",
        "const void *dataSet",
        "TA_Real defaultValue",
        "const char *hint",
        "const char *helpFile"
      ]

      TA_OutputParameterInfo = struct [
        "TA_OutputParameterType type",
        "const char *paramName",
        "TA_OutputFlags flags"
      ]

      TA_PARAM_TYPE = {
        TA_Input_Price: 0,
        TA_Input_Real: 1,
        TA_Input_Integer: 2,
        TA_OptInput_RealRange: 0,
        TA_OptInput_RealList: 1,
        TA_OptInput_IntegerRange: 2,
        TA_OptInput_IntegerList: 3,
        TA_Output_Real: 0,
        TA_Output_Integer: 1
      }.freeze

      # Order here is load-bearing: it's the order TA-Lib expects bundled
      # price arrays to be given in (e.g. `atr([high, low, close], ...)`).
      TA_FLAGS = {
        TA_InputFlags: {
          TA_IN_PRICE_OPEN: 0x00000001,
          TA_IN_PRICE_HIGH: 0x00000002,
          TA_IN_PRICE_LOW: 0x00000004,
          TA_IN_PRICE_CLOSE: 0x00000008,
          TA_IN_PRICE_VOLUME: 0x00000010,
          TA_IN_PRICE_OPENINTEREST: 0x00000020,
          TA_IN_PRICE_TIMESTAMP: 0x00000040
        },
        TA_OptInputFlags: {
          TA_OPTIN_IS_PERCENT: 0x00100000,
          TA_OPTIN_IS_DEGREE: 0x00200000,
          TA_OPTIN_IS_CURRENCY: 0x00400000,
          TA_OPTIN_ADVANCED: 0x01000000
        },
        TA_OutputFlags: {
          TA_OUT_LINE: 0x00000001,
          TA_OUT_DOT_LINE: 0x00000002,
          TA_OUT_DASH_LINE: 0x00000004,
          TA_OUT_DOT: 0x00000008,
          TA_OUT_HISTO: 0x00000010,
          TA_OUT_PATTERN_BOOL: 0x00000020,
          TA_OUT_PATTERN_BULL_BEAR: 0x00000040,
          TA_OUT_PATTERN_STRENGTH: 0x00000080,
          TA_OUT_POSITIVE: 0x00000100,
          TA_OUT_NEGATIVE: 0x00000200,
          TA_OUT_ZERO: 0x00000400,
          TA_OUT_UPPER_LIMIT: 0x00000800,
          TA_OUT_LOWER_LIMIT: 0x00001000
        }
      }.freeze

      extern "int TA_Initialize()"
      extern "int TA_Shutdown()"
      extern "int TA_GetFuncHandle(const char *name, const void **handle)"
      extern "int TA_GetFuncInfo(const void *handle, const TA_FuncInfo **funcInfo)"
      extern "int TA_GetInputParameterInfo(const void *handle, unsigned int paramIndex, const TA_InputParameterInfo **info)"
      extern "int TA_GetOptInputParameterInfo(const void *handle, unsigned int paramIndex, const TA_OptInputParameterInfo **info)"
      extern "int TA_GetOutputParameterInfo(const void *handle, unsigned int paramIndex, const TA_OutputParameterInfo **info)"
      extern "int TA_ParamHolderAlloc(const void *handle, void **allocatedParams)"
      extern "int TA_ParamHolderFree(void *params)"
      extern "int TA_SetInputParamIntegerPtr(void *params, unsigned int paramIndex, const TA_Integer *value)"
      extern "int TA_SetInputParamRealPtr(void *params, unsigned int paramIndex, const TA_Real *value)"
      extern "int TA_SetInputParamPricePtr(void *params,
                                           unsigned int paramIndex,
                                           const TA_Real *open,
                                           const TA_Real *high,
                                           const TA_Real *low,
                                           const TA_Real *close,
                                           const TA_Real *volume,
                                           const TA_Real *openInterest)"
      extern "int TA_SetOptInputParamInteger(void *params, unsigned int paramIndex, TA_Integer optInValue)"
      extern "int TA_SetOptInputParamReal(void *params, unsigned int paramIndex, TA_Real optInValue)"
      extern "int TA_SetOutputParamIntegerPtr(void *params, unsigned int paramIndex, TA_Integer *out)"
      extern "int TA_SetOutputParamRealPtr(void *params, unsigned int paramIndex, TA_Real *out)"
      extern "int TA_GetLookback(const void *params, TA_Integer *lookback)"
      extern "int TA_CallFunc(const void *params,
                              TA_Integer startIdx,
                              TA_Integer endIdx,
                              TA_Integer *outBegIdx,
                              TA_Integer *outNbElement)"

      # Immutable snapshots of TA-Lib's introspection structs, built once
      # per function name and memoized in @function_info_cache.
      InputParam  = Data.define(:type, :name, :flags)
      OptInput    = Data.define(:type, :name, :flags, :display_name, :default_value, :hint)
      OutputParam = Data.define(:type, :name, :flags)
      FuncInfo    = Data.define(:name, :group, :hint, :handle, :inputs, :opt_inputs, :outputs) do
        def price_input? = inputs.first&.type == TA_PARAM_TYPE[:TA_Input_Price]
      end

      class << self
        # Looks up (and memoizes) a function's full signature via TA-Lib's
        # abstract interface. Returns nil if `name` isn't a TA-Lib function
        # (TA_GetFuncHandle matches case-insensitively).
        def function_info(name)
          (@function_info_cache ||= {}).fetch(name) { @function_info_cache[name] = build_function_info(name) }
        end

        def function_info_map = (@function_info_cache ||= {}).dup

        def available? = !function_info("SMA").nil?

        def method_missing(name, *args)
          return super unless respond_to_missing?(name)

          call_func(name.to_s, args)
        end

        # :reek:BooleanParameter -- include_private is Ruby's own required
        # respond_to_missing? signature, not something this method chose.
        def respond_to_missing?(name, include_private = false) = !function_info(name.to_s).nil? || super

        private

        def build_function_info(name)
          handle_ptr = get_function_handle(name)
          return nil unless handle_ptr

          info_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
          check_ta_return_code(TA_GetFuncInfo(handle_ptr, info_ptr.ref))
          raw = TA_FuncInfo.new(info_ptr)

          FuncInfo.new(
            name: raw["name"].to_s,
            group: raw["group"].to_s,
            hint: raw["hint"].to_s,
            handle: handle_ptr,
            inputs: collect_inputs(handle_ptr, raw["nbInput"]),
            opt_inputs: collect_opt_inputs(handle_ptr, raw["nbOptInput"]),
            outputs: collect_outputs(handle_ptr, raw["nbOutput"])
          )
        end

        def collect_inputs(handle_ptr, count)
          collect_params(handle_ptr, count, TA_InputParameterInfo, method(:TA_GetInputParameterInfo)) do |raw_input|
            InputParam.new(type: raw_input["type"], name: raw_input["paramName"].to_s, flags: raw_input["flags"])
          end
        end

        def collect_opt_inputs(handle_ptr, count)
          collect_params(handle_ptr, count, TA_OptInputParameterInfo, method(:TA_GetOptInputParameterInfo)) do |raw_opt|
            OptInput.new(type: raw_opt["type"], name: raw_opt["paramName"].to_s, flags: raw_opt["flags"],
                         display_name: raw_opt["displayName"].to_s, default_value: raw_opt["defaultValue"], hint: raw_opt["hint"].to_s)
          end
        end

        def collect_outputs(handle_ptr, count)
          collect_params(handle_ptr, count, TA_OutputParameterInfo, method(:TA_GetOutputParameterInfo)) do |raw_output|
            OutputParam.new(type: raw_output["type"], name: raw_output["paramName"].to_s, flags: raw_output["flags"])
          end
        end

        def collect_params(handle_ptr, count, struct_type, getter)
          count.times.map do |i|
            ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
            check_ta_return_code(getter.call(handle_ptr, i, ptr.ref))
            yield struct_type.new(ptr)
          end
        end

        def get_function_handle(name)
          handle_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
          ret_code = TA_GetFuncHandle(name, handle_ptr.ref)
          return nil if ret_code == TA_FUNC_NOT_FOUND

          check_ta_return_code(ret_code)
          handle_ptr
        end

        # Calls a TA-Lib function.
        #
        # @param func_name [String]
        # @param args [Array] positional input arrays (bundled as an
        #   array-of-arrays for TA_Input_Price parameters, e.g.
        #   `[[high, low, close]]`), optionally followed by a trailing
        #   Hash of optional parameters.
        # @return [Array, Hash] a bare Array for single-output functions,
        #   a Hash keyed by snake_cased output name for multi-output ones.
        def call_func(func_name, args)
          options = extract_options!(args)
          validate_inputs!(args)
          info = function_info!(func_name)

          with_parameter_holder(info.handle) do |params_ptr|
            setup_input_parameters(params_ptr, args, info)
            setup_optional_parameters(params_ptr, options, info)
            calculate_lookback(params_ptr) # validates params before TA_CallFunc
            calculate_results(params_ptr, args, info)
          end
        end

        def extract_options!(args)
          args.last.is_a?(Hash) ? args.pop : {}
        end

        def function_info!(func_name)
          function_info(func_name) || raise(TALibError, "Unknown TA-Lib function: #{func_name}")
        end

        def with_parameter_holder(handle_ptr)
          params_ptr = create_parameter_holder(handle_ptr)
          yield params_ptr
        ensure
          TA_ParamHolderFree(params_ptr)
        end

        def validate_inputs!(arrays)
          raise TALibError, "Input arrays cannot be empty" if arrays.empty?
          raise TALibError, "Input must be arrays" unless arrays.all?(Array)
          raise TALibError, "Input arrays cannot be empty" if arrays.any?(&:empty?)
          raise TALibError, "Input arrays must contain only numbers" unless arrays.all? { |arr| arr.flatten.all?(Numeric) }
        end

        def create_parameter_holder(handle_ptr)
          params_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
          check_ta_return_code(TA_ParamHolderAlloc(handle_ptr, params_ptr.ref))
          params_ptr
        end

        def calculate_lookback(params_ptr)
          lookback_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT)
          check_ta_return_code(TA_GetLookback(params_ptr, lookback_ptr))
          lookback_ptr[0, Fiddle::SIZEOF_INT].unpack1("l")
        end

        def setup_input_parameters(params_ptr, input_arrays, info)
          input_arrays.each_with_index do |array, index|
            input = info.inputs[index]
            raise TALibError, "#{info.name}: too many input arrays given" unless input

            case input.type
            when TA_PARAM_TYPE[:TA_Input_Price]
              setup_price_inputs(params_ptr, index, array, input.flags)
            when TA_PARAM_TYPE[:TA_Input_Real]
              check_ta_return_code(TA_SetInputParamRealPtr(params_ptr, index, prepare_double_array(array)))
            when TA_PARAM_TYPE[:TA_Input_Integer]
              check_ta_return_code(TA_SetInputParamIntegerPtr(params_ptr, index, prepare_integer_array(array)))
            end
          end
        end

        def setup_price_inputs(params_ptr, index, price_data, flags)
          required_flags = extract_flags(flags, :TA_InputFlags)
          data_pointers = Array.new(6) { Fiddle::Pointer.malloc(0) }

          required_flags.each_with_index do |flag, i|
            array = price_data[i]
            raise TALibError, "Missing price array for flag #{flag} at index #{i}" if array.nil?

            data_pointers[TA_FLAGS[:TA_InputFlags].keys.index(flag)] = prepare_double_array(array)
          end

          check_ta_return_code(TA_SetInputParamPricePtr(params_ptr, index, *data_pointers))
        end

        def setup_optional_parameters(params_ptr, options, info)
          info.opt_inputs.each_with_index do |opt_input, index|
            param_name = normalize_parameter_name(opt_input.name).to_sym
            next unless options.key?(param_name)

            check_ta_return_code(set_optional_parameter(params_ptr, index, options[param_name], opt_input.type))
          end
        end

        # :reek:ControlParameter -- dispatches on TA-Lib's own
        # TA_OptInputParameterType tag (Real vs. Integer); something has
        # to branch on that C-API classification somewhere.
        def set_optional_parameter(params_ptr, index, value, type)
          case type
          when TA_PARAM_TYPE[:TA_OptInput_RealRange], TA_PARAM_TYPE[:TA_OptInput_RealList]
            TA_SetOptInputParamReal(params_ptr, index, value)
          when TA_PARAM_TYPE[:TA_OptInput_IntegerRange], TA_PARAM_TYPE[:TA_OptInput_IntegerList]
            TA_SetOptInputParamInteger(params_ptr, index, value)
          end
        end

        def prepare_double_array(array)
          ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE * array.length)
          ptr[0, Fiddle::SIZEOF_DOUBLE * array.length] = array.map(&:to_f).pack("d*")
          ptr
        end

        def prepare_integer_array(array)
          ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT * array.length)
          ptr[0, Fiddle::SIZEOF_INT * array.length] = array.map(&:to_i).pack("l*")
          ptr
        end

        def calculate_results(params_ptr, input_arrays, info)
          input_size = info.price_input? ? input_arrays[0][0].length : input_arrays[0].length
          output_ptrs = setup_output_buffers(params_ptr, input_size, info)

          begin
            actual_size = call_ta_func(params_ptr, input_size)
            format_output_results(output_ptrs, actual_size, info)
          ensure
            output_ptrs.each(&:free)
          end
        end

        def call_ta_func(params_ptr, input_size)
          out_begin = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT)
          out_size = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT)
          check_ta_return_code(TA_CallFunc(params_ptr, 0, input_size - 1, out_begin, out_size))
          out_size[0, Fiddle::SIZEOF_INT].unpack1("l")
        ensure
          out_begin.free
          out_size.free
        end

        def setup_output_buffers(params_ptr, size, info)
          info.outputs.each_with_index.map do |output, index|
            ptr =
              case output.type
              when TA_PARAM_TYPE[:TA_Output_Real] then Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE * size)
              when TA_PARAM_TYPE[:TA_Output_Integer] then Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT * size)
              end

            ret_code =
              case output.type
              when TA_PARAM_TYPE[:TA_Output_Real] then TA_SetOutputParamRealPtr(params_ptr, index, ptr)
              when TA_PARAM_TYPE[:TA_Output_Integer] then TA_SetOutputParamIntegerPtr(params_ptr, index, ptr)
              end
            check_ta_return_code(ret_code)

            ptr
          end
        end

        def format_output_results(output_ptrs, size, info)
          results = output_ptrs.zip(info.outputs).map do |ptr, output|
            case output.type
            when TA_PARAM_TYPE[:TA_Output_Real] then ptr[0, Fiddle::SIZEOF_DOUBLE * size].unpack("d#{size}")
            when TA_PARAM_TYPE[:TA_Output_Integer] then ptr[0, Fiddle::SIZEOF_INT * size].unpack("l#{size}")
            end
          end

          return results.first if results.length == 1

          info.outputs.map { normalize_parameter_name(it.name).to_sym }.zip(results).to_h
        end

        def extract_flags(value, type)
          TA_FLAGS[type].select { |_k, v| value.anybits?(v) }.keys
        end

        def normalize_parameter_name(name)
          name.sub(/^(optIn|outReal|outInteger|out|in)/, "")
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .tr("-", "_")
              .downcase
        end

        def check_ta_return_code(code)
          return if code == TA_SUCCESS

          raise TALibError, TA_ERROR_MESSAGES.fetch(code) { "Undefined TA-Lib error (Error code: #{code})" }
        end
      end

      # Keyed by TA-Lib's raw TA_RetCode values (ta_common.h) — see the
      # comment above TA_SUCCESS/TA_FUNC_NOT_FOUND for why these aren't
      # also named constants.
      TA_ERROR_MESSAGES = {
        1 => "TA-Lib not initialized, please call TA_Initialize first", # TA_LIB_NOT_INITIALIZE
        2 => "Bad parameter, please check input parameters",            # TA_BAD_PARAM
        3 => "Memory allocation error, possibly insufficient memory",   # TA_ALLOC_ERR
        4 => "Function group not found",                                # TA_GROUP_NOT_FOUND
        6 => "Invalid handle",                                          # TA_INVALID_HANDLE
        7 => "Invalid parameter holder",                                # TA_INVALID_PARAM_HOLDER
        8 => "Invalid parameter holder type",                           # TA_INVALID_PARAM_HOLDER_TYPE
        9 => "Invalid parameter function",                              # TA_INVALID_PARAM_FUNCTION
        10 => "Input parameters not fully initialized",                 # TA_INPUT_NOT_ALL_INITIALIZE
        11 => "Output parameters not fully initialized",                # TA_OUTPUT_NOT_ALL_INITIALIZE
        12 => "Start index out of range",                               # TA_OUT_OF_RANGE_START_INDEX
        13 => "End index out of range",                                 # TA_OUT_OF_RANGE_END_INDEX
        14 => "Invalid list type",                                      # TA_INVALID_LIST_TYPE
        15 => "Invalid object",                                         # TA_BAD_OBJECT
        16 => "Operation not supported",                                # TA_NOT_SUPPORTED
        5000 => "TA-Lib internal error",                                # TA_INTERNAL_ERROR
        0xFFFF => "Unknown error",                                      # TA_UNKNOWN_ERR
        TA_FUNC_NOT_FOUND => "Function not found"
      }.freeze

      ret_code = TA_Initialize()
      raise TALibError, "TA_Initialize failed (code #{ret_code})" unless ret_code == TA_SUCCESS

      at_exit { TA_Shutdown() }
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
