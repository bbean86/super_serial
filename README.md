# SuperSerial

[![Build Status](https://travis-ci.org/bbean86/super_serial.svg?branch=master)](https://travis-ci.org/bbean86/super_serial)
[![Code Climate](https://codeclimate.com/github/bbean86/super_serial.png)](https://codeclimate.com/github/bbean86/super_serial)
## Installation

Add this line to your application's Gemfile:

    gem 'super_serial'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install super_serial

## Usage

Consider the following class: 

``` 
class SuperHero < ActiveRecord::Base 
  include SuperSerial 
  
  super_serialize :features, name: 'Batman', invincible: false, height: 72, weakness: nil
end
```

The first parameter supplied dictates the column the serialized data will be stored in. The remaining key-value pairs indicate the name and default value of the data you want to serialize. Under the hood, it serializes an OpenStruct in the features column on SuperHero. It then defines accessor methods for each key-value pair, or "entry". 

``` 
superman = SuperHero.new 
=> #<SuperHero id: 1, features: #<OpenStruct name='Batman', invincible=false, height=72, weakness=nil>>

superman.name
=> 'Batman'

superman.name = 'Superman' 
=> 'Superman'

superman.invincible
=> false

superman.invincible = true 
=> true

superman.weakness 
=> nil 

superman.weakness = 'kryptonite' 
=> 'kryptonite'

superman.save 
=> true 

superman 
=> #<SuperHero id: 1, features: #<OpenStruct name='Superman', invincible=true, height=72, weakness='kryptonite'>>
```

### Handling Default Value Types 

If a default value is supplied, its type will be inferred and used to validate any values you attempt to store. SuperSerial uses ActiveRecord-style automatic type conversions for any convertible values. 

``` 
superman.invincible = 1 
=> 1 

superman.save 
=> true 

superman.invincible 
=> true

superman.invincible = 'NOPE' 
=> 'NOPE' 

superman.save 
=> true 

superman.invincible 
=> false 

superman.height = '75' 
=> '75' 

superman.save 
=> true

superman.height
=> 75 

superman.height = 'Batman' 
=> 'Batman' 

superman.save 
=> false 

superman.errors.full_messages.first 
=> 'height can only be stored as a fixnum' 
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
