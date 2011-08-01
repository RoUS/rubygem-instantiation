# -*- coding: utf-8 -*-
# :stopdoc:
#
# Documentation is located with the appropriate bits of code.
#
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

# :startdoc:

require 'rubygems'

require 'pp'
require 'ruby-debug'
Debugger.start

#
# = Enhanced constructor module
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
#      attr_accessor(:ivar1)
#      def initialize(*args)
#        super
#          :
#      end
#    end
#
#    obj = Foo.new(:ivar1 => 'val1')
#    obj.ivar1
#    => "val1"
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
module PreInit

  #
  # Simple class for the limited settings used by the PreInit#initialize
  # constructor.
  #
  class Settings

    #
    # The possible settings defined for easier method processing.
    #
    Names = [
             :on_NameError,
             :default,
            ]

    #
    # Default value for instance variables specified only by name.
    #
    attr_accessor(:default)

    #
    # Action to take if there's a problem with a variable name.
    #
    attr_reader(:on_NameError)

    #
    # === Description
    #
    # Create a new instance of the current class, and set instance variables
    # in it according to the key/value pairs in any hashes that were passed.
    #
    # :call-seq:
    # new<i>[(*args)]</i> => <i>object</i>
    # new<i>[(*args)] { |obj,*args| block }</i> => <i>object</i>
    #
    # === Arguments
    # [<i>*args</i>] <i>Array</i> of <i>Hash</i> (zero or more).
    #                An optional collection of name/value pairs.
    #                The names (keys) will be treated as names of
    #                instance variables, and the values as their
    #                initial contents.
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
    #
    # === Examples
    #  class Foo
    #    include PreInit
    #  end
    #  ex_1 = Foo.new(:ivar1 => 1, 'ivar2' => ['an', 'array'])
    #  => #<Foo:0xb7551b50 @ivar2=["an", "array"], @ivar1=1>
    #
    #  ex_2 = Foo.new({ :op1 => 1 }, 17) { |o,*args|
    #    args.each_with_index do |arg,i|
    #      o.instance_variable_set("@new_ivar_#{i}".to_sym, arg)
    #    end
    #  }
    #  => #<Foo:0xb7547de4 @new_ivar_0=17>
    #
    # === Exceptions
    # [<tt>NameError</tt>] The name in one of the tuples could not be converted
    #                      to an instance variable name.
    #
    # [<i>settings</i>] <i>Hash</i>.  Control settings for how the
    #                  <i>PreInit</i> constructor should handle its
    #                  operation when processing <i>*args</i>.  (See
    #                  the link:#preinit_settings section for details.)
    def initialize(*args)
      self.default = nil
      self.on_NameError = :raise
      return unless (arg[0].kind_of?(Hash))
      arg[0].each { |k,v| self.send(k.to_sym, v) }
    end

    #
    # Set the 'wha
    def on_NameError=(val)
      unless ([ :convert, :ignore, :raise ].include?(val))
        raise ArgumentError.new("unrecognised action: #{val.inspect}")
      end
      @on_NameError = val
    end

    def [](*args)
      return self.send(*args) if (Names.include?(args[0]))
      raise ArgumentError.new("unrecognised setting: #{args[0].inspect}")
    end
    alias_method(:[]=, :[])

  end

end
