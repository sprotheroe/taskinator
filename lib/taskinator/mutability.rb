module Taskinator
  module Mutability

    def set_mutable_args(args, mutables)
      # add mutable args from process store to calling task
      mutable_keys = mutables.keys
      positions = {}
      args.each_with_index do |arg, idx|
        if mutable_keys.include?(arg)
          # Replace placeholder symbol with actual value
          args[idx] = mutables[arg]
          positions[idx] = arg
        end
      end
      positions
    end

    def get_mutable_args(args, placeholders, process)
      # retrieve mutable args and save in persistent store for process
      new_mutables = {}
      placeholders.each do |idx, key|
        new_mutables[key] = args[idx]
      end
      merged_mutables = process.mutables.merge(new_mutables)
      process.persist_mutables(merged_mutables)
    end
  end

  class Process
    attr_reader :mutables

    def capture_mutables(arg_defs, arg_vals)
      key = Taskinator.mutable_args_options_key
      mutables = []      

      arg_defs.each_with_index do |arg_def, idx|
        if arg_def.is_a?(Hash) && arg_def.values.include?(key)
          mutables << [arg_def.keys.first, arg_vals[idx]]
          arg_vals[idx] = arg_def.keys.first
        end
      end
    
      @mutables = Hash[mutables]
    end
  end
end
