# my_string = "%{[@metadata][kafka_topic_producer]}"

# puts "#{my_string}"

# my_substring = my_string[0..1]

# puts "#{my_substring}"

# my_integer = "15"
# num = Integer(my_integer) rescue nil
# if( num != nil)
#     puts "#{num}"
# end

my_integer_string = "15s"
num = Integer(my_integer_string) rescue nil
if( num != nil)
    puts "#{my_integer_string} is a number: #{num}"
else
    puts "#{my_integer_string} is a string"
end

my_int = 15
num = Numberic(my_int) rescue nil
if( num != nil)
    puts "my_int: #{my_int} is a number: #{num}"
else
    puts "my_int: #{my_int} is a string"
end

my_string = 500

foo = my_string if( my_string.is_a? String ) rescue nil
# if( my_string.is_a? Numeric )
#     puts "my_string Is a number"
#     my_string = nil
# else
#     puts "my_string Is a string"
# end

if (foo == nil)
    puts "my_string Is a nil"
# elsif (foo == true)
#     puts "my_string Is a NOT nil"
else
    puts "my_string Is #{foo}"
end




# num = String(my_string) rescue nil
# if( num != nil)
#     puts "my_string Is a string"
# else
#     puts "my_string Is a number"
# end

# num = Integer(my_string) rescue nil
# if( num.nil?)
#     puts "my_string Is a number"
# else
#     puts "my_string Is a string"
# end

# puts "Is a number foo"