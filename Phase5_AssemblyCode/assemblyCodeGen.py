import re

f = open("dead_code_removed.txt","r")
f1 = open("testing.r","r")

list_of_lines = f.readlines()
list_of_lines1 = f1.readlines()

arith = ['+','-','*','/']
arith_ass = {'+':"ADD",'-':"SUB",'*':"MUL",'/':"DIV"}
relop = ['<','>','<=','>=','==','!=']
relop_ass = {'<':'GEZ','>':'LEZ','<=':'GZ','>=':'LZ','==':'NEZ','!=':'EZ'}
logic = ['&&','||'] 

keywords = ['IF','FALSE','GOTO','print']
islevel = lambda s : bool(re.match(r"^L[0-9]*$", s))		#to check if it is a level variable
istemp = lambda s : bool(re.match(r"^T[0-9]*$", s))		#to check if it is a temporary variable
isid = lambda s : bool(re.match(r"^[A-Za-z][A-Za-z0-9_]*$", s)) #to check if it is an identifier
isnum = lambda s: bool(s.isdigit())				#to check if it is a constant

def printAssCode(list_of_lines):
	"""
	Prints the lines of the assembly code passed as a parameter
	"""
	for line in list_of_lines:
		print(line)

def addLine(list_of_toks):
	"""
	
	"""
	final_line = list_of_toks[0]
	for tok in list_of_toks[1:]:
		final_line = final_line+' '+tok
	return final_line

def assemblyCodeGeneration(list_of_lines):
	"""
	
	"""
	lengths = []
	final_list = []
	reg = 0
	exps = dict()
	expl = dict()
	levels = []
	for i in range(len(list_of_lines)):
		line = list_of_lines[i].strip('\n')
		toks = line.split()
		length = len(line.split())
		if(length == 2 and islevel(toks[1])):
			levels.append(toks[1])

		if(length == 5):
			#print("****",line) 
			if(islevel(toks[4])):
				levels.append(toks[4])
			if(toks[3] not in logic and toks[0] not in keywords):
				str1=''
				var = {'1':'','2':''}
				temp = reg
				if(isid(toks[2])):
					str1 = str1 + addLine(["LD","R"+str(reg),',',toks[2]]) + '\n'
					var['1'] = "R" + str(reg)
					reg = reg + 1
				else:
					var['1'] = "#" + toks[2]
				if(isid(toks[4])):
					str1 = str1 + addLine(["LD","R"+str(reg),',',toks[4]]) + '\n'
					var['2'] = "R" + str(reg)
					reg = reg + 1
				else:
					var['2'] = "#" + toks[4]
				if(toks[3] in arith):
					str1 = str1 + addLine([arith_ass[toks[3]],'R'+str(temp),',',var['1'],',',var['2']]) + '\n'
					str1 = str1 + addLine(["ST",toks[0],',','R'+str(temp)])
					exps[toks[0]] = str1
				if(toks[3] in relop):
					str1 = str1 + addLine(["SUB",'R'+str(temp),',',var['1'],',',var['2']]) + '\n'
					str1 = str1 + addLine(['B'+relop_ass[toks[3]],'R'+str(temp),','])
					exps[toks[0]] = str1
					list_of_lines[i] = ''
				reg = temp 
				#print(str1)
			if(toks[3] in logic):
				expl[toks[0]] = addLine(toks[2:])
				list_of_lines[i] = ''
			if(toks[0] in keywords and toks[2] in expl):
				toks[2] = expl[toks[2]]
				list_of_lines[i] = addLine(toks)
				#print(list_of_lines[i])
	#print(levels)			
		
		
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		lengths.append(length)
		if(length == 1 and toks[0][:-1] in levels):
			final_list.append('\n'+toks[0])

		if(length == 2):
			if(toks[0] == "GOTO"):
				str1 = addLine(["BR",toks[1]])
				final_list.append(str1)
			else:
				final_list.append(line)
				#print(length,line)
				
		
		if(length == 3):
			if(isid(toks[0]) and toks[1] == '=' and isnum(toks[2])):
				str1 = addLine(["ST",toks[0],",","#"+toks[2]])
				final_list.append(str1)
			else:
				str1 = addLine(["LD","R"+str(reg),",",toks[2]]) + '\n'
				str1 = str1 + addLine(["ST",toks[0],",","R"+str(reg),toks[2]])
				final_list.append(str1)

		if(length == 5):
			if(toks[0] in keywords and toks[2] in exps):
				final_list.append(exps[toks[2]]+' '+toks[4])
				exps.pop(toks[2])
			elif(toks[0] in exps):
				final_list.append(exps[toks[0]])
		
		if(length == 7):
			if(toks[2] in exps):
				final_list.append(exps[toks[2]]+' '+toks[6])
			if(toks[4] in exps):
				final_list.append(exps[toks[4]]+' '+toks[6])
			#print(length,line)
	#print(set(lengths))
	return final_list

print()
print("#"*11,"Source Code",'#'*11)
for line in list_of_lines1:
	print(line.strip('\n'))

print("#"*10,"Optimised ICG",'#'*10)
for line in list_of_lines:
	print(line.strip('\n'))

print()
final_list = assemblyCodeGeneration(list_of_lines)
print("#"*6,"Assembly Code Generated","#"*6)
printAssCode(final_list)



