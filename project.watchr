watch( '.*\.(rb|yml)' ) do |something|
  system "clear"
  puts
  puts "#{something} was saved. Running tests..."
  puts
  system "rake test"
  puts
end
