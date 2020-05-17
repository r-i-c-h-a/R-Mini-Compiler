import re

f = open("output.txt","r")

list_of_lines = f.readlines()

arith = ['+','-','*','/']
logic = ['<','>','<=','>=','==','!=']
rel = ['&&','||'] 
keywords = ['IF','FALSE','GOTO','print']
islevel = lambda s : bool(re.match(r"^L[0-9]*$", s))		#to check if it is a level variable
istemp = lambda s : bool(re.match(r"^T[0-9]*$", s))		#to check if it is a temporary variable
isid = lambda s : bool(re.match(r"^[A-Za-z][A-Za-z0-9_]*$", s)) #to check if it is an identifier
isnum = lambda s: bool(s.isdigit())				#to check if it is a constant


def printICG(list_of_lines):
	"""
	Prints the lines of the ICG passed as a parameter
	"""
	for line in list_of_lines:
		print(line)

def final_ICG(list_of_lines):
	"""
	Substitutes for all the temporaries referring to constants/identifiers
	eg.
	BEFORE:
		T1 = a
		T2 = b
		T3 = T1 + T2
		c = T3
	AFTER:
		T3 = a + b
		c = T3
	"""
	temp_val = dict()	#stores temp as key and constants/identifiers as value
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		if(length == 3):
			if (istemp(toks[0]) and toks[1] == '=' and isid(toks[2]) or isnum(toks[2])):
				if toks[0] not in temp_val:
					temp_val[toks[0]] = toks[2]
	final_list=[]	#stores the final list of lines in the ICG after substitution
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		if(length>=1 and toks[0] not in temp_val):
			for i in range(1,length):
				if toks[i] in temp_val:
					toks[i] = temp_val[toks[i]]
			final_list.append(' '.join(toks))
	return final_list
			
def constant_propagation(list_of_lines,comp=[]):
	"""
	If any of the constants or temporaries contain constants, they are propagated as per their presence in the ICG
	eg.
	BEFORE:
		b = 2
		c = 3
		T1 = b * c
	AFTER:
		b=2
		c=3
		T1 = 2 * 3
	"""
	ident_temp = dict() #stores identifiers/temporaries as key and constants as value
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		if(length == 3):
			if (toks[0] and toks[1] == '=' and isnum(toks[2])):
				if toks[0] not in ident_temp:
					ident_temp[toks[0]] = toks[2]
	final_list = [] #stores the final list of lines in the ICG after constants are propagated
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		if(length == 5 and toks[3] in arith):
			for i in range(1,length):
				if toks[i] in ident_temp:
					toks[i] = ident_temp[toks[i]]
		if(length == 3 and toks[1] == '=' and toks[2] in ident_temp):
			toks[2] = ident_temp[toks[2]]
		if not(length == 3 and istemp(toks[0])):
			final_list.append(' '.join(toks))
	#returns 0 if the new ICG generated is the same as the last one else 1
	if(final_list == comp):
		return final_list,0
	else:
		return final_list,1

def constant_folding(list_of_lines,comp=[]):
	"""
	Evaluates of the constant expressions in the ICG
	eg.
	BEFORE:
		T1 = 2 * 3
		T3 = 8 / 4
	AFTER:
		T1 = 6
		T3 = 2
	"""
	final_list=[] #stores the final list of lines after constant folding is performed
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		if(length == 5):
			if (isnum(toks[2]) and toks[3] in arith and isnum(toks[4])):
				toks=[toks[0],'=',str(eval(toks[2]+toks[3]+toks[4]))]
		final_list.append(' '.join(toks))
	if(final_list == comp):
		return final_list,0
	else:
		return final_list,1

def temp_const_propagation(list_of_lines):
	"""
	Performs constant propagation on all the unnecessary temporaries
	"""
	temp_val = dict()
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		if(length == 5):
			if (istemp(toks[0]) and toks[1] == '=' and toks[3] in arith):
				if(isnum(toks[2]) or (not(istemp(toks[2])) and isid(toks[2]))): 
					if(isnum(toks[4]) or (not(istemp(toks[4])) and isid(toks[4]))):
						temp_val[toks[0]] = ' '.join(toks[2:])
	final_list = []
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		if(length == 3 and toks[2] in temp_val):
			toks[2] = temp_val[toks[2]]
		flag = 1
		for i in toks:
			if i in temp_val:
				flag = 0
		if flag:
			final_list.append(' '.join(toks))
	return final_list


def dict_of_tokens_usage(list_of_lines):
	"""
	Checks the usage count of all the tokens in the ICG
	"""
	tokens = {}
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		for i in toks:
			if istemp(i) or isid(i) and (not(islevel(i)) and not(i in keywords)):
				if i not in tokens:
					tokens[i] = 0
				tokens[i] = tokens[i] + 1
	return tokens

def dead_code_elimination(list_of_lines):
	"""
	Elimination of dead code, i.e., line of code that is not used in the program after definition
	"""
	token_use = dict_of_tokens_usage(list_of_lines)
	final_list = []
	for line in list_of_lines:
		line = line.strip('\n')
		toks = line.split()
		length = len(line.split())
		flag = 1
		for i in range(length):
			if toks[i] in token_use and token_use[toks[i]] <= 1:
					flag = 0
		if flag:
			final_list.append(' '.join(toks))
	return final_list

print('-'*32,"ICG" , '-'*32)
ICG_list = final_ICG(list_of_lines)
printICG(ICG_list)
'''prints the ICG after replacing all the temporaries with the constant/ identifier values'''

flag1 = 1
flag2 = 1 
n = 1

"""
Usually constant propagation and constant folding are performed together.
We also perform them together n times until they cannot be applied any further.
"""
const_prop_list,flag1 = constant_propagation(ICG_list)
const_fold_list,flag2 = constant_folding(const_prop_list)

while int(flag1) or int(flag2):
	const_prop_list,flag1 = constant_propagation(const_fold_list,const_prop_list)
	const_fold_list,flag2 = constant_folding(const_prop_list,const_fold_list)
	n=n+1

final_prop_list = temp_const_propagation(const_fold_list)
print('-'*6,'Constant Propagation and Constant Folding Done',n,'times','-'*6)
printICG(final_prop_list)
'''prints the ICG after performing code propagation and code optimisation n times'''

print('-'*8,'Dead Code Elimination Done','-'*8)
dead_code_elim_list = dead_code_elimination(final_prop_list)
printICG(dead_code_elim_list)
