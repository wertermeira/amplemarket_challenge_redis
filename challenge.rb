#!/usr/bin/ruby

@block_count = 0
@block_array = []
@database = []

def comamnd_line
  print 'Enter the TYPE, variable name and value like a "SET a 10"'
  @variable_and_value = gets.chomp
end

def database
  type, variable, value = @variable_and_value.split(' ')
  case type
  when 'BEGIN', 'COMMIT', 'ROLLBACK'
    commands_with_transaction(type)
  when 'SET'
    set_variable(variable, value)
  when 'GET'
    query(variable)
  when 'UNSET'
    @database.each { |hash| hash.delete(variable) if hash[:variable] == variable }
    puts "UNSET #{variable} #{value}"
  when 'NUMEQUALTO'
    numeroqualto(value)
  else
    return puts 'Invalid command'
  end

  return if @block_count.zero?

  @block_array[@block_count - 1] = @database unless type == 'ROLLBACK' && type == 'COMMIT'
end

def commands_with_transaction(type)
  case type
  when 'BEGIN'
    @block_count += 1
    @database = []
    puts 'BEGIN'
  when 'COMMIT'
    commit_transaction
  when 'ROLLBACK'
    rollback_transaction
  end
end

def set_variable(variable, value)
  @database.each do |hash|
    next unless hash[:variable] == variable

    hash[:value] = value
    return puts "Variable #{variable} has been updated to #{value}"
  end
  @database << { variable: variable, value: value }
  puts "SET #{variable} #{value}"
end

def query(variable)
  @database.each do |hash|
    return puts "GET #{variable} #{hash[:value]}" if hash[:variable] == variable
  end
  puts "GET #{variable} NULL"
end

def numeroqualto(value)
  count = 0
  @database.each do |hash|
    count += 1 if hash[:value] == value
  end
  puts "NUMEQUALTO #{value} #{count}"
end

def commit_transaction
  return puts 'NO TRANSACTION' if @block_count.zero?

  @database = []
  @block_array.each do |block|
    block.each do |hash|
      next if @database.select { |h| h[:variable] == hash[:variable] }.any?

      @database.push(hash)
    end
  end
  @block_count = 0
  puts 'COMMIT'
end

def rollback_transaction
  return puts 'NO TRANSACTION' if @block_count.zero?

  puts @block_array.delete_at(@block_count -= 1)
end

loop do
  comamnd_line
  break if @variable_and_value.split(' ')[0] == 'END'

  database
end
