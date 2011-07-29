# -*- coding: utf-8 -*-
#
# = preinit.rb - Class providing an enhanced constructor
#
# Author::      Ken Coar
# Copyright::   Copyright © 2011 Ken Coar
# License::     Apache Licence 2.0
#
# == Synopsis
#
#    require 'rubygems'
#    require 'preinit'
#
#    class Foo
#      include PreInit
#        :
#      def initialize(*args)
#        super
#          :
#      end
#    end
#
# == Description
#
# The <i>initialize</i> method provided by PreInit scans its argument
# list for hashes.  For each hash it finds, it treats the keys as
# instance variable names, and sets them to the corresponding values.
#
# <i><b>N.B.</b></i>: PreInit does <i>not</i> set up access methods
# for the instance variables!  It either uses those already defined,
# or sets the variables directly without going through an accessor method.
#--
# Copyright © 2010 Ken Coar
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License. You may
# obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#++

#
# Make sure our current directory is in the include path.
#
self.tap do
  this_dir = File.dirname(__FILE__)
  unless ($:.include?(this_dir) || $:.include?(File.expand_path(this_dir)))
    $:.unshift(this_dir)
  end
end

require 'rubygems'
require 'versionomy'

module PreInit

  #
  # Version number as a <i>Versionomy</i> object.
  #
  Version = Versionomy.parse('0.1.0')
  #
  # Version number as an extractable string.
  #
  VERSION = Version.to_s.freeze

  #
  # Hash of controls affecting how the constructor functions.
  #
  # [<tt>:default</tt>] <i>Any</i>.  Default value to assign if an
  #                     instance variable is specified without one
  #                     (<i>e.g.</i> <tt>new({}, 'varname')</tt>).
  # [<tt>:on_NameError</tt>] <i>Symbol</i>.  Action to take if an
  #                          invalid instance variable name appears
  #                          in the hash.
  #                          [<tt>:raise</tt>] A <i>NameError</i> exception
  #                                            will be raised identifying
  #                                            the invalid name.
  #                          [<tt>:ignore</tt>] The key/value pair with
  #                                             the invalid name will be
  #                                             silently ignored.
  #                          [<tt>:convert</tt>] An attempt will be made
  #                                              to make the name valid
  #                                              (<i>e.g.</i>, replacing
  #                                              illegal characters with
  #                                              '<tt>_</tt>', <i>etc.</i>).
  #
  attr_reader(:preinit_options)

  #
  # === Description
  #
  # Create a new instance of the current class, and set instance variables
  # in it according to the key/value pairs in any hashes that were passed.
  #
  # :call-seq:
  # new<i>(*args)</i> => <i>object</i>
  # new<i>[(options[, *args])] { |obj,*args| block }</i> => <i>object</i>
  #
  # === Arguments
  # [<i>*args</i>] <i>Array</i> of <i>Hash</i> (zero or more).
  #                An optional collection of name/value pairs.
  #                The names (keys) will be treated as names of
  #                instance variables, and the values as their
  #                initial contents.
  # [<i>options</i>] <i>Hash</i>.  Control settings for how the
  #                  <i>PreInit</i> constructor should handle its
  #                  operation when processing <i>*args</i>.  (See
  #                  the link:#preinit_options section for details.)
  #
  # === Examples
  #  class Foo
  #    include PreInit
  #  end
  #  ex_1 = Foo.new(:ivar1 => 1, 'ivar2' => ['an', 'array'])
  #  => #<Foo:0xb7551b50 @ivar2=["an", "array"], @preinit_options={}, @ivar1=1>
  #
  #  ex_2 = Foo.new({ :op1 => 1 }, 17) { |o,*args|
  #    args.each_with_index do |arg,i|
  #      o.instance_variable_set("@new_ivar_#{i}".to_sym, arg)
  #    end
  #  }
  #  => #<Foo:0xb7547de4 @preinit_options={:op1=>1}, @new_ivar_0=17>
  #
  # === Exceptions
  # [<tt>NameError</tt>] The name in one of the tuples could not be converted
  #                      to an instance variable name.
  #
  def initialize(*args)
    @preinit_options = {}
    if (block_given?)
      if (args[0].kind_of?(Hash))
        @preinit_options = args.shift
      end
      yield(self, *args)
    else
      load_attrs(*args) unless (args.empty?)
    end
  end

  #
  # === Description
  #
  # Create a new <i>BitString</i> object.  By default, it will be unbounded and
  # all bits clear.
  #
  # :call-seq:
  # new<i>([val], [bitcount])</i> => <i>BitString</i>
  # new<i>(length) {|index| block }</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>val</i>] <i>Array</i>, <i>Integer</i>, <i>String</i>, or <i>BitString</i>. Initial value for the bitstring.  If a <i>String</i>, the value must contain only '0' and '1' characters; if an <i>Array</i>, all elements must be 0 or 1.  Default 0.
  # [<i>bitcount</i>] <i>Integer</i>.  Optional length (number of bits) for a bounded bitstring.
  #
  # === Examples
  #  bs = BitString.new(4095)
  #  bs.to_s
  #  => "111111111111"
  #  bs.bounded?
  #  => false
  #
  #  bs = BitString.new('110000010111', 12)
  #  bs.bounded?
  #  => true
  #  bs.to_i
  #  => 3095
  #
  #  bs = BitString.new(12) { |pos| pos % 2 }
  #  bs.to_s
  #  => "101010101010"
  #
  # === Exceptions
  # [<tt>RangeError</tt>] <i>val</i> is a string, but contains non-binary digits.
  #
  #
  # Allow loading of values from a hash into an existing object, not
  # just at instantiation.  Kinda like Hash.merge! -- but also not.
  #
  def load_attrs(*args)
    while (arg = args.shift)
      next unless (arg.kind_of?(Hash))
      arg.each do |attr,val|
        ivar = attr
        #
        # TODO: Vet method name
        #
        # Here is where we need to worry about a key not being a
        # valid method name (like 'foo-bar' => 'val').  What to do with
        # such?
        #
        setmeth = "#{ivar.to_s}=".to_sym
        #
        # If there's already a 'foo=' method, use it rather than
        # just setting the instance variable directly -- thus preserving
        # any special processing the class has for the variable.
        #
        if (self.respond_to?(setmeth))
          self.send(setmeth, val)
        else
          self.instance_variable_set("@#{ivar.to_s}".to_sym, val)
        end
      end
    end
  end

end
