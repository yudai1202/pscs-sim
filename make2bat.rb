#!/usr/bin/ruby -s
# -*- coding: euc-jp -*-
# -*- Ruby -*-

def usage
  name = File::basename $0
  print <<EOU
#{name}: Makefile ���� Windows �ѥХå��ե���������
(��)
  #{name} < Makefile
  for m in */Makefile; do ./#{name} < "$m" > `dirname $m`/make.bat; done
(���ץ������)
  -help      �ޤ��� -h     �� ���Υ�å�������ɽ��
EOU
end

#####################################

if ($help || $h)
  usage
  exit 0
end

$command = Hash.new{|h,k| h[k] = Array.new}

ARGF.each_line{|line|
  line.chomp!
  case line
  when /^(\w+):/
    $target = Regexp.last_match[1]
    $default ||= $target
  when /^\t(.*)$/
    $command[$target].push Regexp.last_match[1]
  when /^\s*$/
  else
    raise "Sorry. Not supported: #{line}"
  end
}

if_part = $command.keys.map{|t|
  %!if "%1" == "#{t}" goto #{t}!
}.join "\n"

rule = [
        ['/', '\\'],
        [/\S+\.rb/, 'ruby \0'],
#        [/@echo(.*)$/, ['@echo off', 'echo\1', '@echo on'].join("\n")],
       ]

do_part = $command.each_pair.map{|t,cs|
  c = cs.join "\n"
  rule.each{|from, to| c.gsub! from, to}
  <<-_EOS_
:#{t}
@echo on
#{c}
@echo off
goto end
  _EOS_
}.join "\n"

#############################

puts <<_EOS_
@echo off
rem This file is automatically generated.

#{if_part}
goto #{$default}

#{do_part}
:end
_EOS_