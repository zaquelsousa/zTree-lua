local current_directory = vim.fn.getcwd()

local current_directory_content = vim.fn.readdir(current_directory)

local filetype = require("ztree-lua.types")


--node
function createNode(content)
	return {
		value = content,
		children = {},
		parent = nil
	}
end

root = createNode(current_directory_content)

for _, content in ipairs(root.value) do
	local childnode = createNode(content)
	childnode.parent = root.value
	table.insert(root.children, childnode)

end



-- so vai criar os nodes quando clica pora entrar na pasta, performace kkkk
function newNodes(path, father)
	local content = vim.fn.readdir(path)
	node = createNode(content)

	for _, content in ipairs(node.value) do
		local childnode = createNode(content)
		childnode.parent = father
		table.insert(node.children, childnode)

	end
	local nodes = {}

	for _, child in ipairs(node.children) do
		print(child.value)
		if vim.fn.isdirectory(path .. "/" .. child.value) == 1 then
			print("sim")
			table.insert(nodes, ">  " .. child.value)
		else
			local icon = ""
			for i = #child.value, 1, -1 do
				local char = child.value:sub(i, i)
				icon = icon .. char
				if char == '.' then
					break
				end
			end
			icon = string.reverse(icon)
			local file_icon = filetype[icon] or ""
			table.insert(nodes, "> " .. file_icon .. " ".. child.value) 
		end
	end

	return nodes
end





function showNodes(node)
  local output = {}

  for _, child in ipairs(node.children) do
	  if vim.fn.isdirectory(child.value) == 1 then
		  table.insert(output, ">  " .. child.value)  	
	  else
		  local icon = "" 

		  for i = #child.value, 1, -1 do
		  	local char = child.value:sub(i, i)
			icon = icon .. char

			if char == '.' then
				break
			end
		  end
		  
		  icon = string.reverse(icon)
		  local file_icon = filetype[icon] or ""
		  table.insert(output, "> " .. file_icon .. " ".. child.value) 
	end
  end

  





  vim.cmd("vsplit")
  vim.cmd("vertical resize 25")
  vim.cmd("enew")
  
  vim.wo.number = true
  vim.wo.relativenumber = true

  vim.bo.bufhidden = "wipe"
  vim.bo.buftype = "nofile"
  vim.bo.swapfile = false
  vim.bo.buflisted = false
  vim.api.nvim_buf_set_name(0, "zTree")

  vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
  vim.api.nvim_buf_set_option(0, "modifiable", true)

  --grebe only the buffer active, that will be where is the tree content
  local buf = vim.api.nvim_get_current_buf()
  vim.keymap.set("n", "<CR>", function()
	  local cursor = vim.api.nvim_win_get_cursor(0)
	  local line_num = cursor[1]
	  local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

	  -- Faz algo com a linha
	  if string.match(line, ">  ") then
		local dirname = ""
		for i = #line, 1, -1 do
			local char = line:sub(i, i)
			if char == " " then
				break
			end
			dirname = dirname .. char
		end
		dirname = string.reverse(dirname)
		local nodepath = current_directory .. "/" .. dirname
		local nodes = newNodes(nodepath, dirname)
		local insert_pos = line_num
		local lines_to_insert = {}

		for _, node in ipairs(nodes) do
			table.insert(lines_to_insert, node)
		end

		vim.api.nvim_buf_set_lines(buf, insert_pos, insert_pos, false, lines_to_insert)


	  else


		  local filename  = "" 
		  for i = #line, 1, -1 do
			  local char = line:sub(i, i)
			  if char == " " then
				  break
			  end
			  filename = filename .. char
		  end
		  filename = string.reverse(filename)
		  local filepath = current_directory .. "/" .. filename
		  vim.cmd("wincmd l")
		  vim.cmd("edit".. filepath)
	  end
  end, { buffer = buf, nowait = true, silent = true })
end

showNodes(root)


--[[
for _, content in ipairs(current_directory_content) do

	if vim.fn.isdirectory(content) == 1 then
		print(content, " dir")
	
	else
		print(content, " file")
	end

end
--]]
