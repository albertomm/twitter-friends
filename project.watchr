watch( '.*\.rb' ) do |something|
  puts
  puts "#{something} was modified"
  puts
  system "rake test"
  puts
end
