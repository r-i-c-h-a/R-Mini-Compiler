import re

f = open("dead_code_removed.txt","r")
f1 = open("testing.r","r")
f2 = open("ICG.txt","r")
f3 = open("final.txt","r")

list_of_lines = f.readlines()				#Optimized code
list_of_lines1 = f1.readlines()				#Source code
list_of_lines2 = f2.readlines()				#Initial ICG
list_of_lines3 = f3.readlines()				#After applying constant propagation and folding 5 times

arith = ['+','-','*','/']							#list of arithmetic operators
arith_ass = {'+':"ADD",'-':"SUB",'*':"MUL",'/':"DIV"}				#dictionary of corresponding assembly code operations

relop = ['<','>','<=','>=','==','!=']						#list of relational operators
relop_ass = {'<':'GEZ','>':'LEZ','<=':'GZ','>=':'LZ','==':'NEZ','!=':'EZ'}	#dictionary of corresponding assembly code operations

logic = ['&&','||'] 								#list of logical operators

keywords = ['IF','FALSE','GOTO','print']					#list of keywords

islevel = lambda s : bool(re.match(r"^L[0-9]*$", s))		#to check if it is a level variable
istemp = lambda s : bool(re.match(r"^T[0-9]*$", s))		#to check if it is a temporary variable
isid = lambda s : bool(re.match(r"^[A-Za-z][A-Za-z0-9_]*$", s)) #to check if it is an identifier
isnum = lambda s: bool(s.isdigit())				#to check if it is a constant
isstr = lambda s: bool(s.startswith('"') and s.endswith('"'))	#to check if it is a string

def printAssCode(list_of_lines):
	"""
	Prints the lines of the assembly code passed as a parameter
	"""
	for line in list_of_lines:
		print(line)

def addLine(list_of_toks):
	"""
	Concatenation of the list of tokens passed
	"""
	final_line = list_of_toks[0]
	for tok in list_of_toks[1:]:
		final_line = final_line+' '+tok
	return final_line

def releaseReg(reg_use,var_use):
	maxi = -1
	reg = ''
	var = ''
	for i in reg_use:
		if(var_use[i]):
			if(var_use[i][0]>maxi):
				maxi = var_use[i][0]
				reg = reg_use[i]
				var = i
		else:
			reg = reg_use[i]
			var = i
			print(var,reg)
			return reg,var
	print(var,reg)
	return reg,var
		

def assemblyCodeGeneration(list_of_lines):
	"""
	Generates assembly code on passing an optimized ICG
	Assembly code for arithmetic, logical and relational expressions

	1) Arithmetic Expression:
		BEFORE
			b = 5 + c
		AFTER
			LD R0 , c
			ADD R0 , #5 , R0
			ST b , R0

	Similarily for SUB, MUL and DIV

	2) Logical Expression:
		BEFORE
			T0 = a < 5
			IF FALSE T0 GOTO L0
		AFTER
			LD R0 , a
			SUB R0 , R0 , #5
			BGEZ R0 , L0 

	Similarily for other logical operators

	3) Relational Expression:
		BEFORE
			T17 = i >= 2 
			T18 = i <= 3
			T16 = T17 && T18 
			IF FALSE T16 GOTO L2
		AFTER
			LD R0 , i
			SUB R0 , R0 , #2
			BLZ R0 , L2
			LD R0 , i
			SUB R0 , R0 , #3
			BGZ R0 , L2

	Simlarily for or(||) operator

	Assignment Operation with identifier or immediate value
		BEFORE
			a = 5
			b = a
		AFTER
			ST a , #5
			LD R0 , a
			ST b , R0

	"""

	final_list = []			#list of lines of assembly code
	reg = 0				#register count
	exps = dict() 			#dictionary with tokens as key and assembly code as value for arithmetic and relational expressions
	expl = dict()			#dictionary with tokens as key and assembly code as value for logical expressions
	expa = dict()
	levels = []			#list of labels 
	var_use = dict()		#stores next use
	reg_avail = ["R0","R1","R2","R3","R4","R5","R6","R7"]
	#reg_in_use = []			
	reg_use = dict()		#stores register associated with variable
	#for i in range(8):
	#reg_var["R"+str(i)] = ""

	#fill in next use
	for i in range(len(list_of_lines)):
		line = list_of_lines[i].strip('\n')
		toks = line.split()
		length = len(line.split())
		for j in toks:
			if((isid(j) or istemp(j)) and j not in keywords and not(islevel(j))):
				if(j in var_use):
					var_use[j].append(i)
				else:
					var_use[j]=[]
					var_use[j].append(i)
		
	#print(var_use)
	for i in range(len(list_of_lines)):
		#print(i,list_of_lines[i],var_use)
		line = list_of_lines[i].strip('\n')
		toks = line.split()
		length = len(line.split())
		str1 = ''

		#populate list of labels used in the code
		if(length == 2 and islevel(toks[1])):
			levels.append(toks[1])

		if(length == 5): 
			if(islevel(toks[4])):
				levels.append(toks[4])

			if(toks[3] not in logic and toks[0] not in keywords and not(islevel(toks[4]))):
				var_use[toks[0]].pop(0)
				str1=''				#contains the generated assembly code
				var = {'1':'','2':''}		#values are the 2 operands
				#temp = reg

				#checks if first operand is an identifier or an immediate value
				if(isid(toks[2])):
					var_use[toks[2]].pop(0)
					if(reg_avail and toks[2] not in reg_use):
						var['1'] = reg_avail.pop(0)
						str1 = str1 + addLine(["LD",var['1'],',',toks[2]]) + '\n'
						reg_use[toks[2]] = var['1']
					elif(toks[2] in reg_use):
						var['1'] = reg_use[toks[2]]
					else:
						r,v = releaseReg(reg_use,var_use)
						reg_use.pop(v)
						reg_use[toks[2]] = r
						str1 = str1 + addLine(["ST",v,",",r]) + '\n'
						str1 = str1 + addLine(["LD",r,',',toks[2]]) + '\n'
						var['1'] = reg_use[toks[2]]
					#reg = reg + 1
				else:
					var['1'] = "#" + toks[2]

				#checks if first operand is an identifier or an immediate value
				if(isid(toks[4])):
					var_use[toks[4]].pop(0)
					if(reg_avail and toks[4] not in reg_use):
						var['2'] = reg_avail.pop(0)
						str1 = str1 + addLine(["LD",var['2'],',',toks[4]]) + '\n'
						reg_use[toks[4]] = var['2']
					elif(toks[4] in reg_use):
						var['2'] = reg_use[toks[4]]
					else:
						r,v = releaseReg(reg_use,var_use)
						reg_use.pop(v)
						reg_use[toks[4]] = r
						str1 = str1 + addLine(["ST",v,",",r]) + '\n'
						str1 = str1 + addLine(["LD",r,',',toks[4]]) + '\n'
						var['2'] = reg_use[toks[4]]
					#reg = reg + 1
				else:
					var['2'] = "#" + toks[4]

				#assembly code for arithmetic expressions
				if(toks[3] in arith):
					if(reg_avail and toks[0] not in reg_use):
						reg_use[toks[0]] = reg_avail.pop(0)
						str1 = str1 + addLine([arith_ass[toks[3]],reg_use[toks[0]],',',var['1'],',',var['2']]) #+ '\n' 
						#str1 = str1 + addLine(["ST",toks[0],',','R'+str(temp)])
						exps[toks[0]] = str1
					elif(toks[0] in reg_use):
						str1 = str1 + addLine([arith_ass[toks[3]],reg_use[toks[0]],',',var['1'],',',var['2']]) #+ '\n' 
						#str1 = str1 + addLine(["ST",toks[0],',','R'+str(temp)])
						exps[toks[0]] = str1
					else:
						r,v = releaseReg(reg_use,var_use)
						reg_use.pop(v)
						reg_use[toks[0]] = r
						str1 = str1 + addLine(["ST",v,",",r]) + '\n'
						str1 = str1 + addLine([arith_ass[toks[3]],reg_use[toks[0]],',',var['1'],',',var['2']]) #+ '\n' 
						#str1 = str1 + addLine(["ST",toks[0],',','R'+str(temp)])
						exps[toks[0]] = str1

				#assembly code for relational operations
				if(toks[3] in relop):
					if(reg_avail):
						str1 = str1 + addLine(["SUB",reg_avail[0],',',var['1'],',',var['2']]) + '\n'
						str1 = str1 + addLine(['B'+relop_ass[toks[3]],reg_avail[0],','])
						exps[toks[0]] = str1
						list_of_lines[i] = ''
					else:
						r,v = releaseReg(reg_use,var_use)
						reg_use.pop(v)
						str1 = str1 + addLine(["ST",v,",",r]) + '\n'
						reg_avail.append(r)
						str1 = str1 + addLine(["SUB",r,',',var['1'],',',var['2']]) + '\n'
						str1 = str1 + addLine(['B'+relop_ass[toks[3]],r,','])
						exps[toks[0]] = str1
						list_of_lines[i] = ''

			#populate the dictionary of logical expressions
			if(toks[3] in logic):
				expl[toks[0]] = addLine(toks[2:])
				list_of_lines[i] = ''

			#substitite the relational expressions in place
			if(toks[0] in keywords and toks[2] in expl):
				toks[2] = expl[toks[2]]
				list_of_lines[i] = addLine(toks)	
		
	#print(exps)
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		str1 = ''

		#print the level variable as it is in assembly code
		if(length == 1 and toks[0][:-1] in levels):
			final_list.append('\n'+toks[0])

		"""
		Unconditional Break
			BEFORE
				GOTO L2
			AFTER
				BR L2
		"""
		if(length == 2):
			if(toks[0] == "GOTO"):
				str1 = addLine(["BR",toks[1]])
				final_list.append(str1)
			else:
				final_list.append(line)
				
		"""
		
		"""
		if(length == 3):
			var_use[toks[0]].pop(0)
			if(isid(toks[0]) and toks[1] == '=' and isstr(toks[2])):
				if(toks[0] not in reg_use and reg_avail):
					reg_use[toks[0]] = reg_avail.pop(0)
					str1 = '\n' + addLine(["string: .asciz",toks[2]]) + '\n'
					str1 = str1 + addLine(["MOV",reg_use[toks[0]],",","string"])
					final_list.append(str1)
				elif(toks[0] in reg_use):
					str1 = '\n' + addLine(["string: .asciz",toks[2]]) + '\n'
					str1 = str1 + addLine(["MOV",reg_use[toks[0]],",","string"])
					final_list.append(str1)
				else:
					r,v = releaseReg(reg_use,var_use)
					reg_use.pop(v)
					reg_use[toks[0]] = r
					str1 = str1 + addLine(["ST",v,",",r]) + '\n'
					str1 = str1 + addLine(["string: .asciz",toks[2]]) + '\n'
					str1 = str1 + addLine(["MOV",reg_use[toks[0]],",","string"])
					final_list.append(str1)
					

			elif(isid(toks[0]) and toks[1] == '=' and isnum(toks[2])):
				if(toks[0] not in reg_use and reg_avail):
					reg_use[toks[0]] = reg_avail.pop(0)
					str1 = addLine(["MOV",reg_use[toks[0]],",","#"+toks[2]])
					final_list.append(str1)
				elif(toks[0] in reg_use):
					str1 = addLine(["MOV",reg_use[toks[0]],",","#"+toks[2]])
					final_list.append(str1)
				else:
					r,v = releaseReg(reg_use,var_use)
					reg_use.pop(v)
					reg_use[toks[0]] = r
					str1 = str1 + addLine(["ST",v,",",r]) + '\n'
					str1 = str1 + addLine(["MOV",reg_use[toks[0]],",","#"+toks[2]])
					final_list.append(str1)

			else:
				var_use[toks[2]].pop(0)
				if(reg_avail and toks[0] not in reg_use):
					reg_use[toks[0]] = reg_avail.pop(0)
				else:
					r,v = releaseReg(reg_use,var_use)
					reg_use.pop(v)
					reg_use[toks[0]] = r
					str1 = addLine(["ST",v,",",r]) + '\n' 

				if(reg_avail and toks[2] not in reg_use):
					reg = reg_avail.pop(0)
					str1 = str1 + addLine(["LD",reg,",",toks[2]]) + '\n'
					str1 = str1 + addLine(["MOV",reg_use[toks[0]],",",reg])
					reg_use[toks[2]] = reg
					final_list.append(str1)
				elif(toks[2] in reg_use):
					str1 = str1 + addLine(["MOV",reg_use[toks[0]],",",reg_use[toks[2]]])
					final_list.append(str1)
				else:
					r,v = releaseReg(reg_use,var_use)
					reg_use.pop(v)
					reg_use[toks[2]] = r
					str1 = str1 + addLine(["ST",v,",",r]) + '\n'
					str1 = str1 + addLine(["LD",r,",",toks[2]]) + '\n'
					str1 = str1 + addLine(["MOV",reg_use[toks[0]],",",reg_use[toks[2]]])
					final_list.append(str1)

		#Conditional break using relational assembly code previously defined
		if(length == 5):
			if(toks[0] in keywords and toks[2] in exps):
				final_list.append(exps[toks[2]]+' '+toks[4])
				exps.pop(toks[2])
			elif(toks[0] in exps):
				#print("*************",exps[toks[0]])
				final_list.append(exps[toks[0]])
		
		#Conditional break using logical assembly code previously defined
		if(length == 7):
			if(toks[2] in exps):
				final_list.append(exps[toks[2]]+' '+toks[6])
			if(toks[4] in exps):
				final_list.append(exps[toks[4]]+' '+toks[6])
	for i in reg_use:
		final_list.append(addLine(["ST",i,",",reg_use[i]]))

	return final_list


print()
print("#"*14,"Source Code",'#'*14)
for line in list_of_lines1:
	print(line.strip('\n'))

print("#"*20,"ICG",'#'*20)
for line in list_of_lines2:
	print(line.strip('\n'))
print()

print("#"*8,"Constant Propagation and Constant Folding done 5 times",'#'*8)
for line in list_of_lines3:
	print(line.strip('\n'))
print()

print("#"*8,"Optimised ICG after Dead Code Elimination",'#'*8)
for line in list_of_lines:
	print(line.strip('\n'))

print()
final_list = assemblyCodeGeneration(list_of_lines)
print("#"*6,"Assembly Code Generated","#"*6)
printAssCode(final_list)
