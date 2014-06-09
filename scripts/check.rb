rows = File.readlines("data/import/matches.csv")

header = rows.take(1)

grouped_by_ rows.drop(1).group_by { |col| col.split(",")[0] }

# rows.each do |row|
# 	puts row
# end