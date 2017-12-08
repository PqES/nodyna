vet = [[0,8,6], [5,3,1,9]]
currentIndexes = []
for i in 0..vet.size-1
  currentIndexes[i] = 0
end
breakTheWhile = false
countLoop = 0
while(!breakTheWhile)
  countLoop += 1
  newStr = ""
  for i in 0..vet.size-1
    newStr = "#{newStr}#{vet[i][currentIndexes[i]]}"
  end
  puts newStr
  indexToIncrement = vet.size - 1
  currentIndexes[indexToIncrement] += 1
  while(currentIndexes[indexToIncrement] == vet[indexToIncrement].size)
    currentIndexes[indexToIncrement] = 0
    indexToIncrement -= 1
    if(indexToIncrement >= 0)
      currentIndexes[indexToIncrement] += 1
    else
      breakTheWhile = true
      break
    end
  end
end
puts countLoop