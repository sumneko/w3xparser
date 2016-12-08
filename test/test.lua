package.cpath = package.cpath .. [[;.\..\bin\Debug\?.dll]]

local w3xparser = require 'w3xparser'
local slk = w3xparser.slk
local txt = w3xparser.txt
local print_r = require 'print_r'

function io.load(filename)
	local f, e = io.open(filename, "rb")
	if f then
		local content = f:read 'a'
		f:close()
		return content
	else
		return false, e
	end
end

function LOAD(filename)
	local f = assert(io.open(filename, 'rb'))
	local r = lni(f:read 'a')
	f:close()
	return r
end

local function EQUAL(a, b)
	for k, v in pairs(a) do
		if type(v) == 'table' then
			EQUAL(v, b[k])
		else
			assert(v == b[k])
		end
	end
end

local n = 0
local function TEST(script, t)
	n = n + 1
	local name = 'TEST-' .. n
	local r = txt(script)
	local ok, e = pcall(EQUAL, r, t)
	if not ok then
		print(script)
		print('--------------------------')
		print_r(r)
		print('--------------------------')
		print_r(t)
		print('--------------------------')
		error(name)
	end
	local ok, e = pcall(EQUAL, t, r)
	if not ok then
		print(script)
		print('--------------------------')
		print_r(r)
		print('--------------------------')
		print_r(t)
		print('--------------------------')
		error(name)
	end
end

TEST([[
[A]
// [B]
 [C]
 k= 1 
[A]
m=1
 k=2
]]
,
{
  A = { [' k'] = {' 1 ','2'},  ['m'] = {'1'}  }
}
)

-- txt value的切割规则(神TM复杂)
-- 1.如果第一个字符是逗号,则添加一个空串
-- 2.如果当前字符为引号,则匹配到下一个引号,并忽略2端的字符
-- 3.如果当前字符为逗号,则忽略该字符.如果上一个字符是逗号,则添加一个空串
-- 4.否则匹配到下一个逗号,并忽略该字符
local list = {
{'1',        { '1' }},
{',',        { '' }},
{',1',       { '' , '1' }},
{'1,',       { '1' }},
{'1,1',      { '1' , '1' }},
{'"1"',      { '1' }},
{'"1',       { '1' }},
{'1"',       { '1"' }},
{'"1,1"',    { '1,1' }},
{'"1"1',     { '1' , '1' }},
{'"1",1',    { '1' , '1' }},
{'"1","1"',  { '1' , '1' }},
{'1"1"',     { '1"1"' }},
{'1,"1"',    { '1' , '1' }},
{'1,,1',     { '1' , '' , '1' }},
{'1"1"1',    { '1"1"1' }},
{',1"1"1',   { '' , '1"1"1' }},
{'1,"1"1',   { '1' , '1' , '1' }},
{'1",1"1',   { '1"' , '1"1' }},
{'1"1,"1',   { '1"1' , '1' }},
{'1"1",1',   { '1"1"' , '1' }},
{'1"1"1,',   { '1"1"1' }},
{'1,1,1',    { '1' , '1' , '1' }},
{'"1,1,1',   { '1,1,1' }},
{'1",1,1',   { '1"' , '1' ,'1' }},
{'1,"1,1',   { '1' , '1,1' }},
{'1,1",1',   { '1' , '1"' , '1' }},
{'1,1,"1',   { '1' , '1' , '1' }},
{'1,1,1"',   { '1' , '1' , '1"' }},
{',"',       { '' , '' }},
{',",',      { '' , ',' }},
{',","',     { '' , ',' }},
{',",",',    { '' , ',' }},
{',",","',   { '' , ',' , "" }},
{',",",",',  { '' , ',' , ',' }},
{'1,1"',     { '1' , '1"' }},
{'"1"2,3',   { '1' , '2' , '3' }},
}

for _, test in ipairs(list) do
	TEST('[a]\nb=' .. test[1], {a={b=test[2]}})
end

print('test ok!')
