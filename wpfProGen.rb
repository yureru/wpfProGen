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
    properties = properties + indentLevel + Lib::EndPropertiesRegion
    backingFields = backingFields + indentLevel + Lib::EndMembersRegion

    # finds the regions and pastes the generated code
    file.gsub! Lib::RegPropertiesRegion, properties

    file.gsub! Lib::RegMembersRegion, backingFields

    # gets the path without the file 
    path = currentFile.match(Lib::RegPath)

    # fparts is the filename in parts fparts[1] is the name, fparts[2] is the extension (without dot)
    fparts = currentFile.match(Lib::RegFilename)

    #create a temporal filename path
    tempFileWithPath = path[1] + fparts[1] + "_temp" + "." + fparts[2]

    # save temporal file and rename it to the original
    File.open(tempFileWithPath, "w") {|f| f.write(file) }
    File.rename(tempFileWithPath, currentFile) # no need to delete the original before rename

    puts "Created " + p.to_s + " properties for " + "#{currentFile}" + " file\n"
  end
end