# -*- coding: utf-8 -*-
# :stopdoc:
#
# Documentation is down by the module declaration.
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

#
# Make sure our current directory is in the include path.
#
self.tap do
  this_dir = File.dirname(__FILE__)
  unless ($:.include?(this_dir) || $:.include?(File.expand_path(this_dir)))
    $:.unshift(this_dir)
  end
end

# :startdoc:

require 'rubygems'
require 'versionomy'

require 'preinit/settings'

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
  # Version number as a <i>Versionomy</i> object.
  #
  Version = Versionomy.parse('0.1.0')
  #
  # Version number as an extractable string.
  #
  VERSION = Version.to_s.freeze

  #
  # Module 'class' methods defined to avoid polluting instances.
  #
  class << self

    #
    # === Description
    #
    # Handle the turning of a set of tuples into instance variables and values.
    # This is invoked behind the scenes by <i>new</i>, but can be invoked on
    # an existing object in order to update or add values.
    #
    # :call-seq:
    # PreInit.import_instance_variables<i>(object, *args)</i> => <i>object</i>
    # PreInit.import_instance_variables<i>[(*args)] { |obj,*args| block }</i> => <i>object</i>
    #
    # === Arguments
    # [<i>*args</i>] <i>Array</i> of <i>Hash</i> (zero or more).
    #                An optional collection of name/value pairs.
    #                The names (keys) will be treated as names of
    #                instance variables, and the values as their
    #                initial contents.
    #
    # === Examples
    #  class Foo
    #    include PreInit
    #  end
    #  ex_1 = Foo.new
    #  ex_1.load_attrs(:ivar1 => 1, 'ivar2' => ['an', 'array'])
    #  => #<Foo:0xb7551b50 @ivar2=["an", "array"], @ivar1=1>
    #
    #  ex_2 = Foo.new
    #  ex_2.load_attrs(17) { |o,*args|
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
    def import_instance_variables(target, *args)
      while (arg = args.shift)
        next unless (block_given? || arg.kind_of?(Hash))
        arg.each do |*segs|
          if (block_given?)
            yield(target, *segs)
            next
          end
          (ivar, ival) = segs.shift
          #
          # Here is where we need to worry about a key not being a
          # valid method name (like 'foo-bar' => 'val').  What to do with
          # such?
          #
          ivar = ivar.to_s.dup
          if (ivar !~ %r!^[_a-z0-9]+$!i)
            case target.preinit_settings.on_NameError
            when :ignore
              next
            when :convert
              ivar.gsub!(%r![^_a-z0-9]!i, '_')
              ivar.gsub!(%r!_{2,}!, '_')
            when :raise
              raise NameError.new("Illegal instance variable name: '#{ivar}'")
            end
          end
          setmeth = "#{ivar}=".to_sym
          #
          # If there's already a 'foo=' method, use it rather than
          # just setting the instance variable directly -- thus preserving
          # any special processing the class has for the variable.
          #
          if (target.respond_to?(setmeth))
            target.send(setmeth, ival)
          else
            target.instance_variable_set("@#{ivar}".to_sym, ival)
          end
        end
      end
      return target
    end

  end

  #
  # Hash of controls affecting how the constructor functions.
  #
  attr_reader(:preinit_settings)

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
  def initialize(*args, &block)
    @preinit_settings = Settings.new(:on_NameError => :raise)
    if (block_given? || (! args.empty?))
      PreInit.import_instance_variables(*args, &block)
    end
  end

end
