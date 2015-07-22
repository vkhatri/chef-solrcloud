
# Enable Auto Memory -Xmx java option
default['solrcloud']['auto_java_memory'] = true

# Minimum Memory to preserve for system
default['solrcloud']['auto_system_memory'] = 768

# Calculate -Xmx (Multiple of 1024)
if node['solrcloud']['auto_java_memory'] && node['memory'] && node['memory'].key?('total')
  total_memory = (node['memory']['total'].gsub('kB', '').to_i / 1024).to_i
  total_memory_percentage = (total_memory % 1024)
  system_memory = if total_memory < 2048
                    total_memory / 2
                  else
                    if total_memory_percentage >= node['solrcloud']['auto_system_memory'].to_i
                      total_memory_percentage
                    else
                      total_memory_percentage + 1024
                    end
                  end

  java_memory = total_memory - system_memory
  # Making Java -Xmx even
  java_memory += 1 unless java_memory.even?
  default['solrcloud']['java_xmx'] = "#{java_memory}m"
  default['solrcloud']['java_xms'] = "#{java_memory}m"
else
  default['solrcloud']['java_xmx'] = '512m'
  default['solrcloud']['java_xms'] = '512m'
end
