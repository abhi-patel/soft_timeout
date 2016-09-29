# SoftTimeout

SoftTimeout provides feature to set soft expiry time before raising actual Timeout Exception. It allows you to run custom code before raising Timeout::Error. 

Takes soft expiry, hard exipry and a block as argumen. Executes the block after soft expiry time. Raises Timeout error after hard expiry time seconds.
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'soft_timeout'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install soft_timeout

## Usage
```ruby
class MyClass
  def initialize
    @continue_running = true
  end

  def some_important_task
    # Soft timeout at 10 sec. and Raise Timeout::Error after 20 sec
    timeout = SoftTimeout::Timeout.new(10, 20) do
      #This block will be executed after soft expiry time is reached(10 secs here)  
      @continue_running = false
    end

    # Keep checkig if flag is still set to true and then process the chunk. else exit gracefully
    # It will raise Timeout::Error if following block runs for more than hard expiry time(20 secs)
    timeout.soft_timeout do
      100.times do |n|
        if @continue_running
          ...
          some heavy processing (sleep(2))
          ...
        else
          puts 'soft timeout reached'
          ..Finish work, release locks etc...
          return
        end
        
      end
    end
end
```
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abhi-patel/soft_timeout. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

