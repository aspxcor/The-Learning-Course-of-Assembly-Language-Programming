stosb:把al存入es:[di]

lodsb:把ds:[si]存入al

movsb:把ds:[si]存入es:[di]

scasb:

cmp al,es:[di]

di++

​	repe scasb:直到不相等才停止比较

​	repne scasb:直到相等才停止比较
