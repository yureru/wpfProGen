require_relative 'core/lib'
require 'json'
file = File.open("metadata.txt") { |file| file.read }

my_hash = JSON.parse(file)

my_hash.each do | metadata |
  #currentFile is the file specified in the metadata, propertiesGrup is all the properties for that file.
  metadata.each do | currentFile, propertiesGroup | 
    #puts currentFile
    file = File.open(currentFile) { |file| file.read }

    Lib.indentStartingLevel = Lib.numberOfTabs(file, Lib::RegTabIndentationStart)
    indentLevel = Lib.levelsOfIndent(Lib.indentStartingLevel)

    properties = ""
    backingFields = ""
    indentStarting = ""
    insertRegion = true

    p = 0
    propertiesGroup.each_entry do | property | # each group of properties
      i = 0
      p += 1
      arr = Array.new(4)

      property.each_pair do | key, value| # key and valur for each property
        arr[i] = value
        i += 1
      end

      if (insertRegion)
        properties = Lib::BeginPropertiesRegion + "\n\n"
        backingFields = Lib::BeginMembersRegion + "\n\n"
        insertRegion = false
      end
			
      propertyAndBackfield = Lib.createProperty(arr)
      properties += propertyAndBackfield[0]
      backingFields += propertyAndBackfield[1]
    end
    properties = properties + indentLevel + Lib::EndPropertiesRegion + "\n\n"
    backingFields = backingFields + indentLevel + Lib::EndMembersRegion + "\n\n"

    file.gsub! Lib::RegPropertiesRegion, properties

    file.gsub! Lib::RegMembersRegion, backingFields

    # save file and print operations done
    #File.open("TaskModelWrapper.cs", "w") {|f| f.write(file) }
    #puts "Created " + p.to_s + " properties for " + "#{key}" + " file"

    #m = key.match /([^\/]+)(?=\.([0-9a-z]+)(?:[\?#]|$))/
    #indexing at 0 and 1 gives filename, indexing at 2 gives file extension (without dot).
    #puts m[1]

    puts file
    puts "-----------------------------------------------------------------------------"
  end
end