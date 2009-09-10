 File.open('code.txt',File::RDWR|File::TRUNC|File::CREAT) {|hand| Dir['*.cls'].each {|f| hand.puts f; IO.readlines(f).each_with_index{|l,i| hand.puts "#{i+1} #{l}"} }}

