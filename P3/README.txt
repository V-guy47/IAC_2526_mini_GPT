Formato das Instruções :
- li - imm[15,5], rd[4,2], opcode[1,0] (ex: 00101001100 010 00 - 0x2988 - li R2 332)
- add - rs[7,5], rd[4,2], opcode[1,0] (ex: 00000000 100 010 01 - 0x0089 - add R2 R4)
- dot - rs[7,5], rd[4,2], opcode[1,0] (ex: 00000000 110 100 10 - 0x00D2 - dot R4 R6)
- dota - rs2[10,8], rs1[7,5], rd[4,2], opcode[1,0] (ex: 00000 110 100 111 11 - 0x069F - dota R7 R4 R6)

P.S: O nosso Opcode está nos dois bits menos significativos

Como temos 4 instrucoes, para manter o formato o mais simples possivel escolhemos apenas 2 bits para o opcode (2^2 = 4)
A organizacao do datapath tem bastantes parecencas com o processador estudado nas aulas. 
Existe:
	- um Program Counter (PC) que itera para ler a próxima instrucao
	- uma memoria ROM para ler as instrucoes dadas
	- distribuidores para separar os dois principais tipos de instrucoes a utilizar (e os devidos registos)
	- um pequeno banco de registos para guardar os valores das variaveis
	- uma Unidade de Aritmetica e Logica (ALU) personalizada, para acomodar as devidas operacoes

Alem disso, adicionamos:
	- um descodificador (main, canto superior esquerdo) 
	(para decidir se e necessario carregar uma operacao vinda da ALU ou um imediato para os registos)
	- varias saidas do Banco de Registos, trocando simplicidade (hard wired) por eficiencia (menos ciclos de relogio para realizar uma operacao)
	(além disso, o dota utiliza SEMPRE 5 registos ao mesmo tempo: rd, rs1, rs1 + 1, rs2, rs2 + 1)
	- um extensor de sinal para o imediato (11 para 16 bits, prevenindo conflitos com diferencas de bits nos registos)

Para terminar, este sistema e modular, ou seja, se quisermos adicionar mais instruções e possível. 
A instrucao mais compacta tem ainda 5 bits livres, por isso ainda podemos ter 2^5 = 32 instrucoes adicionais, ou eventuais modificacoes a instrucoes ja existentes.