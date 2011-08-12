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

require 'versionomy'

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
#    require 'instantiation'
#
#    class Foo
#      include Instantiation
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
# The <i>initialize</i> method provided by Instantiation scans its argument
# list for hashes.  For each hash it finds, it treats the keys as
# instance variable names, and sets them to the corresponding values.
#
# Instantiation also provides a 'class' method (#import_instance_variables)
# that it uses internally to do the hash-to-instance-variable magic --
# but which can also be used to perform the same magic on any arbitrary
# object even if its class doesn't mix in the Instantiation module.
#
# <i><b>N.B.</b></i>: Mixing in Instantiation does <i>not</i> set up access
# methods for the instance variables it processes!  It either uses
# those already defined, or sets the variables directly without going
# through an accessor method.
#

#:stopdoc:
# :on_NameError
# :use_accessors
# :overwrite_values
# :default_values { :key => defval, ... }
# :require_accessors (?)
#              An optional collection of keywords and their values.
#              [<tt>:default</tt>] <i>Any</i>.  Default value to assign
#                                  if an instance variable is specified
#                                  without one (<i>e.g.</i>,
#                                  <tt>new('varname')</tt>).
#              [<tt>:on_NameError</tt>] <i>Symbol</i>.  Action to take
#                                       if an invalid instance variable
#                                       name appears in the hash.
#                                       [<tt>:raise</tt>] A <i>NameError</i>
#                                                         exception
#                                                         will be raised
#                                                         identifying
#                                                         the invalid name.
#                                       [<tt>:ignore</tt>] The key/value
#                                                          pair with the
#                                                          invalid name
#                                                          will be silently
#                                                          ignored.
#                                       [<tt>:convert</tt>] An attempt will
#                                                           be made to make
#                                                           the name valid
#                                                           (<i>e.g.</i>,
#                                                           replacing
#                                                           illegal
#                                                           characters with
#                                                           '<tt>_</tt>',
#                                                           <i>etc.</i>).
#:startdoc:

#
# A little fribbery to define a shortcut name.
#
module Instantiation
end
CXN = Instantiation unless (defined?(CXN))

#
# Reopen the module to start adding *real* comment.
#
module Instantiation
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

    Options = [
               :on_NameError,
               :overwrite_values,
               :use_accessors,
               :require_accessors,
               :default_values,
              ]

    #
    # === Description
    #
    # Handle the turning of a set of tuples into instance variables
    # and values.  This is invoked behind the scenes by
    # <i>initialize</i>, but can be invoked on an existing object in
    # order to update or add values.
    #
    # :call-seq:
    # Instantiation.import_instance_variables<i>(object, *args)</i> => <i>object</i>
    # Instantiation.import_instance_variables<i>(object, *args) { |obj,*args| block }</i> => <i>object</i>
    #
    # === Arguments
    # [<i>target</i>] <i>Object</i>.  The instance that will potentially
    #                 have instance variables set from the argument list.
    # [<i>*args</i>] <i>Array</i>.  Elements (zero or more) may be
    #                <i>Hash</i> or <i>Instantiation::Settings</i> objects
    #                or any combination thereof.  <i>Instantiation::Settings</i>
    #                objects will be installed (each in turn overriding any
    #                previously encountered) as the controls for the
    #                constructor.
    #                The names (keys) of Hash elements will be treated
    #                as names of instance variables, and the values as their
    #                initial contents.
    #
    # === Examples
    #  ex_1 = Object.new
    #  Instantiation.import_instance_variables(:ivar_1 => 'New string', :zed => :zed)
    #  => #<Object:0xb7403780 @zed=:zed, @ivar_1="New string">
    #
    # === Exceptions
    # [<tt>NameError</tt>] The name in one of the tuples is not a valid
    #                      instance variable name.
    #
    def import_instance_variables(target, tuples, options_p={})
      #
      # If the target doesn't yet have any of our special methods,
      # add them to it.  We count on 'em shortly.
      #
      unless (target.respond_to?(:i12n_on_NameError=))
        target.extend(Instantiation)
      end
      #
      # Get the current settings.
      #
      options = Options.inject({}) { |memo,opsym|
        memo[opsym] = target.__send__(('i12n_' + opsym.to_s).to_sym)
        memo
      }
      #
      # Override with any that were passed in.
      #
      options.merge!(options_p)
      options.each do |opsym,val|
        unless (Options.include?(opsym))
          options.delete(opsym)
          next
        end
        accessor_name = 'i12n_' + opsym.to_s
        target.__send__((accessor_name + '=').to_sym, val)
      end
      #
      # Reset our list to whatever the values have become.
      #
      Options.each do |opsym|
        accessor_name = 'i12n_' + opsym.to_s
        options[opsym] = target.__send__(accessor_name.to_sym)
      end
      #
      # Let's get down to work.
      #
      if (block_given? || tuples.kind_of?(Hash))
        tuples.each do |*segs|
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
          retried = false
          begin
            ivar = ivar.to_s.sub(%r!^:?@*!, '')
            ivar_sym = ('@' + ivar).to_sym
            ivar_setmeth = (ivar + '=').to_sym
            #
            # Check the syntax by trying to set the symbolised name
            # on a test object.  (Can't just do an instance_variable_get
            # on the target because it displays a warning rather than
            # raining an exception.)
            #
            Object.new.instance_variable_set(ivar_sym, nil)
            #
            # Okey, we're still here -- so it's apparently a valid name.
            # If we have a only-set-new restriction, check for that.
            #
            if ((! options[:overwrite_values]) \
                && target.instance_variables.include?(ivar_sym.to_s))
              raise TypeError.new('forbidden by rule: overwrite of ' +
                                  ivar_sym.to_s +
                                  ' by import '
                                  )
            end
            #
            # If there's already a 'foo=' method, potentially use it
            # rather than just setting the instance variable directly
            # -- thus preserving any special processing the class has
            # for the variable.
            #
            if (options[:use_accessors] && target.respond_to?(ivar_setmeth))
              target.__send__(ivar_setmeth, ival)
            else
              target.instance_variable_set(ivar_sym, ival)
            end
          rescue NameError => e
            next if (options[:on_NameError] == :ignore)
            raise if ((options[:on_NameError] == :raise) || retried)
            if (options[:on_NameError] == :convert)
              retried = true
              #
              # Turn bogus characters (sequences of one or more) into single
              # '_' characters.  We only do this once; if we still get an
              # exception, tough noogies.
              #
              ivar.gsub!(%r![^_A-Z0-9]+!i, '_')
              ivar.gsub!(%r!_{2,}!, '_')
              retry
            end
          end
        end
      end
      return target
    end

    def set_NameError_action(target, action)
      action ||= :raise
      unless ([ :raise, :ignore, :convert ].include?(action))
        raise ArgumentError.new("invalid action '#{action.inspect}'")
      end
      code = <<-EOC
        def i12n_on_NameError
          return #{action.inspect}
        end
      EOC
      target.instance_eval(code)
      return action
    end

    def declare_option_accessor(target, opt, val, type)
      methname = 'i12n_' + opt.to_s
      code = <<-EOC
        def #{methname}
          return #{type.eql?(:Boolean) ? (val ? 'true' : 'false') : val}
        end
      EOC
      target.instance_eval(code)
      return target.__send__(methname.to_sym)
    end

  end

  def i12n_default_values=(val)
    return CXN.declare_option_accessor(self,
                                       :default_values,
                                       val,
                                       :nonBoolean)
  end

  def i12n_on_NameError=(action)
    CXN.set_NameError_action(self, action)
    return self.i12n_on_NameError
  end

  def i12n_overwrite_values=(val)
    return CXN.declare_option_accessor(self,
                                       :overwrite_values,
                                       val,
                                       :Boolean)
  end

  def i12n_require_accessors=(val)
    return CXN.declare_option_accessor(self,
                                       :require_accessors,
                                       val,
                                       :Boolean)
  end

  def i12n_use_accessors=(val)
    return CXN.declare_option_accessor(self,
                                       :use_accessors,
                                       val,
                                       :Boolean)
  end

  #
  # These methods are dynamically replaced when new values are set,
  # so these just provide the defaults, as it were.
  #
  def i12n_default_values
    return {}
  end

  def i12n_on_NameError
    return :raise
  end

  def i12n_overwrite_values
    return true
  end

  def i12n_require_accessors
    return false
  end

  def i12n_use_accessors
    return false
  end

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
  # [<i>*args</i>] <i>Array</i>.  Elements (zero or more) may be
  #                <i>Hash</i> or <i>Instantiation::Settings</i> objects
  #                or any combination thereof.  <i>Instantiation::Settings</i>
  #                objects will be installed (each in turn overriding any
  #                previously encountered) as the controls for the
  #                constructor.
  #                The names (keys) of Hash elements will be treated
  #                as names of instance variables, and the values as their
  #                initial contents.
  #
  # === Examples
  #  class Foo
  #    include Instantiation
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
  # [<tt>NameError</tt>] (<i>Raised from Instantiation.import_instance_variables</i>)
  #                      The name in one of the tuples is not a valid
  #                      instance variable name.
  #
  def initialize(hsh_p={}, options_p={}, &block)
    if (block_given? || (! hsh_p.empty?))
      CXN.import_instance_variables(self, hsh_p, options_p, &block)
    end
  end

end
