require "soft_timeout/version"
require 'timeout'
module SoftTimeout

  THIS_FILE = /\A#{Regexp.quote(__FILE__)}:/o
  CALLER_OFFSET = ((c = caller[0]) && THIS_FILE =~ c) ? 1 : 0
  private_constant :THIS_FILE, :CALLER_OFFSET

  class Timeout
    attr_accessor :soft_expiry, :hard_expiry, :error_class, :on_soft_timeout

    def initialize(soft_expiry, hard_expiry, error_class = ::Timeout::Error, &block)
      self.soft_expiry = soft_expiry
      self.hard_expiry = hard_expiry
      self.error_class = error_class
      self.on_soft_timeout = block if block_given?
    end

    def soft_timeout(&block)
      return yield(soft_expiry) if soft_expiry == nil || soft_expiry < 0 || hard_expiry == nil || hard_expiry < 0 || hard_expiry <= soft_expiry
      run_proc_with_error_handling(build_timeout_proc(&block))
    end

    def run_proc_with_error_handling(timeout_proc)
      message = "execution expired".freeze
      begin
        return timeout_proc.call(error_class)
      rescue error_class => e
        bt = e.backtrace
      end

      level = -caller(CALLER_OFFSET).size - 1
      while THIS_FILE =~ bt[level]
        bt.delete_at(level)
      end
      raise(error_class, message, bt)
    end

    def build_timeout_proc
      message = "execution expired".freeze

      proc do |exception|
        begin
          original_thread = Thread.current
          timeout_thread = Thread.start {
            begin
              sleep soft_expiry
            rescue => e
              original_thread.raise e
            else
              on_soft_timeout.call if on_soft_timeout
            end

            begin
              sleep hard_expiry - soft_expiry
            rescue => e
              original_thread.raise e
            else
              original_thread.raise exception, message
            end
          }
          yield(soft_expiry)
        ensure
          if timeout_thread
            timeout_thread.kill
            timeout_thread.join # make sure timeout_thread is dead.
          end
        end
      end
    end
  end


end
