#
# random_password.rb
#
# Copyright 2012 Krzysztof Wilczynski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Puppet::Parser::Functions.newfunction(:random_password, type: :rvalue, doc: <<-EOS
Returns a string of arbitrary length that contains randomly selected characters.

Prototype:

    random_password(n)

Where n is a non-negative numeric value that denotes length of the desired password.

For example:

  Given the following statements:

    $a = 4
    $b = 8
    $c = 16

    notice random_password($a)
    notice random_password($b)
    notice random_password($c)

  The result will be as follows:

    notice: Scope(Class[main]): fNDC
    notice: Scope(Class[main]): KcKDLrjR
    notice: Scope(Class[main]): FtvfvkS9j9wXLsd6
EOS
                                     ) do |*arguments|
  #
  # This is to ensure that whenever we call this function from within
  # the Puppet manifest or alternatively form a template it will always
  # do the right thing ...
  #
  arguments = arguments.shift if arguments.first.is_a?(Array)

  if arguments.empty?
    raise Puppet::ParseError, 'random_password(): Wrong number of arguments ' \
      "given (#{arguments.size} for 1)"
  end

  size = arguments.shift

  # This should cover all the generic numeric types present in Puppet ...
  unless size.class.ancestors.include?(Numeric) || size.is_a?(String)
    raise Puppet::ParseError, 'random_password(): Requires a numeric ' \
      'type to work with'
  end

  # Numbers in Puppet are often string-encoded which is troublesome ...
  size = size.to_i if size.is_a?(String) && size.match(%r{^\d+$})

  if !size.is_a?(Numeric) || size < 0
    raise Puppet::ParseError, 'random_password(): Requires a non-negative ' \
      'integer value to work with'
  end

  # These are quite often confusing ...
  ambiguous_characters = %w[0 1 O I l]

  # Get allowed characters set ...
  set = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  set -= ambiguous_characters

  # Shuffle characters in the set at random and return desired number of them ...
  Array.new(size) do |_i|
    set[rand(set.size)]
  end.join
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
