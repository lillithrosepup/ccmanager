
local thisCol = lvn.sorter.cols[lvn.sorter.curCol]
local input = peripheral.wrap(thisCol.input or lvn.sorter.cols[lvn.sorter.curCol - 1].nextRow)

local function checkCol(col, item)
  local order = col.order or lvn.sorter.defaultOrder

  for _, rowName in ipairs(order) do
    local row = col[rowName]
    if type(row) == "function" then
      if row(item) then
        return rowName
      end
    elseif type(row) == "string" and row == "default" then
      
      -- Loop all lower columns
      local moved
      
      
      for i = lvn.sorter.curCol + 1, #lvn.sorter.cols do
        local col = lvn.sorter.cols[i]
        moved = checkCol(col, item)

        if moved then
          print("col " .. i .. " >> " .. moved)
          break
        else 
          print("col " .. i .. " >> default")
        end 
      end

      if not moved then
        -- Push it to the default row
        return rowName
      else
        -- Push it to the row that was found
        return thisCol.nextRow
      end
    end
  end

  return nil
end

local function loop()
  for slot, item in pairs(input.list()) do
    if item then
      local item = input.getItemDetail(slot, true)

      -- Loop all rows in the current column
      local moved = checkCol(thisCol, item)
      
      if not moved then
        moved = thisCol.nextRow
      end

      input.pushItems(moved, slot)

      if item.name then
        print(item.name .. " >> " .. moved)
      end

    end
  end
end


while true do
  pcall(loop)
  sleep(0.1)
end