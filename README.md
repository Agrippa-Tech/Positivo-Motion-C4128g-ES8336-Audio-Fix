# Linux ES8336 Audio Fix

[![Bash](https://img.shields.io/badge/Bash-5.0+-green)](https://www.gnu.org/software/bash/)
[![ALSA](https://img.shields.io/badge/ALSA-Audio-blue)](https://www.alsa-project.org/)
[![PipeWire](https://img.shields.io/badge/PipeWire-0.3+-orange)](https://pipewire.org/)
[![Plataforma](https://img.shields.io/badge/Plataforma-Linux-lightgrey)](https://www.kernel.org/)

Correção automática para problemas de áudio em notebooks com codec **ESSX8336 / ES8336**, onde o Linux detecta corretamente a placa de som, porém não reproduz áudio nos alto-falantes internos.

O problema ocorre principalmente em equipamentos baseados em **Intel Apollo Lake / Gemini Lake** utilizando **SOF (Sound Open Firmware)**, onde o PipeWire reconhece o dispositivo, o fluxo de áudio é criado, mas a saída física dos alto-falantes não é inicializada corretamente após o login.

---

# Início Rápido

```bash
# Clone o repositório
git clone https://github.com/Agrippa-Tech/Linux-ES8336-Audio-Fix.git

cd Linux-ES8336-Audio-Fix

# Permissão de execução
chmod +x audio-fix.sh

# Execute o script
./audio-fix.sh
```

Após confirmar que o áudio foi restaurado, configure o script para iniciar automaticamente junto com a sessão do usuário.

---

# Sumário

- [Visão Geral](#visão-geral)
- [Problema](#problema)
- [Solução](#solução)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Requisitos](#requisitos)
- [Instalação](#instalação)
- [Automatização na Inicialização](#automatização-na-inicialização)
- [Como Funciona](#como-funciona)
- [Diagnóstico](#diagnóstico)
- [Solução de Problemas](#solução-de-problemas)
- [Caso Real de Teste](#caso-real-de-teste)
- [Contribuindo](#contribuindo)


---

# Visão Geral

Em alguns equipamentos com codec ES8336, o Linux inicializa corretamente todos os componentes de áudio:

- Firmware SOF carregado
- Driver `snd_soc_sof_es8336` ativo
- Codec detectado pelo kernel
- Dispositivos ALSA disponíveis
- PipeWire funcionando

Apesar disso, os alto-falantes permanecem sem áudio.

Sintomas comuns:

- Volume do sistema em 100%
- Testes visuais do PipeWire indicando reprodução
- YouTube e outros aplicativos reproduzindo normalmente
- `pavucontrol` mostrando atividade de áudio
- Nenhum som físico nos speakers internos

Ou seja, o fluxo digital existe, mas a etapa final de ativação do hardware não ocorre corretamente.

---

# Problema

Um diagnóstico típico pode apresentar:

```bash
pactl list cards
```

Com a saída:

```text
analog-output-speaker: Speakers (not available)
```

ou o `pavucontrol` mostrando o medidor de volume se movimentando, porém sem qualquer som nos alto-falantes.

---

# Solução

Este projeto aplica uma sequência de comandos ALSA e PipeWire para reconfigurar o codec ES8336 após o carregamento completo da sessão gráfica.

Fluxo da correção:

```text
        Login do usuário
               |
               v
    Aguarda inicialização do sistema
               |
               v
       Reinicia PipeWire/WirePlumber
               |
               v
    Reconfigura o perfil da placa SOF
               |
               v
       Reativa codec ES8336
               |
               v
       Alto-falantes funcionando
```

---

# Estrutura do Projeto

```text
Linux-ES8336-Audio-Fix/
│
├── audio-fix.sh        # Script principal de correção
├── README.md           # Documentação do projeto
```

---

# Requisitos

## Sistema Operacional

- Linux Mint 21 ou superior
- Ubuntu 22.04 ou superior
- Kernel Linux 6.x recomendado

## Áudio

- ALSA
- PipeWire
- WirePlumber
- Codec ES8336 / ESSX8336

---

# Instalação

## 1. Clonar o repositório

```bash
git clone https://github.com/Agrippa-Tech/Linux-ES8336-Audio-Fix.git

cd Linux-ES8336-Audio-Fix
```

---

## 2. Permitir execução do script

```bash
chmod +x audio-fix.sh
```

---

## 3. Testar manualmente

```bash
./audio-fix.sh
```

Se o som retornar corretamente, prossiga para a automatização.

---

# Automatização na Inicialização

No Linux Mint:

1. Abra **Menu → Aplicativos de Inicialização**
2. Clique em **Adicionar**
3. Configure os campos:

**Nome:**

```text
ES8336 Audio Fix
```

**Comando:**

```text
/caminho/completo/para/audio-fix.sh
```

**Comentário:**

```text
Restaura automaticamente os alto-falantes ES8336 após o login.
```

---

# Como Funciona

O script executa as seguintes etapas:

1. Aguarda alguns segundos para que a sessão gráfica seja totalmente carregada.
2. Reinicia os serviços:
   - PipeWire
   - PipeWire Pulse
   - WirePlumber
3. Seleciona o perfil correto da placa de som.
4. Reconfigura os dispositivos ALSA.
5. Reativa a saída dos alto-falantes.

Tudo ocorre automaticamente e não exige intervenção do usuário após o login.

---

# Diagnóstico

## Verificar se o codec foi reconhecido

```bash
cat /proc/asound/cards
```

Exemplo:

```text
0 [sofessx8336]: sof-essx8336
```

---

## Verificar o carregamento do driver

```bash
sudo dmesg | grep -i es83
```

Exemplo:

```text
es8326 i2c-ESSX8326:00: assuming static mclk
Topology file: intel/sof-tplg/sof-glk-es8336-ssp0.tplg
```

---

## Verificar o servidor de áudio

```bash
pactl info
```

Deve indicar algo semelhante:

```text
Server Name: PulseAudio (on PipeWire)
```

---

# Solução de Problemas

## O áudio aparece no medidor, mas não sai som

Este é exatamente o problema tratado por este projeto.

Execute:

```bash
./audio-fix.sh
```

ou encerre e reinicie a sessão do usuário.

---

## O dispositivo de áudio não aparece

Verifique:

```bash
cat /proc/asound/cards
```

Se não houver referência a `sof-essx8336`, o problema provavelmente está relacionado ao kernel, firmware SOF ou BIOS do equipamento.

---

## O problema retorna após reiniciar o computador

Certifique-se de que o script está configurado em:

**Menu → Aplicativos de Inicialização**

para ser executado automaticamente após o login.

---

# Caso Real de Teste

Este projeto foi desenvolvido e validado em um notebook:

| Componente | Informação |
|---|---|
| Modelo | Positivo C4128G-14-AX |
| Sistema | Linux Mint 21.3 Virginia |
| Kernel | 6.8.0 |
| Driver | snd_soc_sof_es8336 |
| Codec | ESSX8336 |
| Firmware | SOF |
| Servidor de áudio | PipeWire 0.3.48 |
| Sintoma | Aplicações reproduziam áudio, porém os alto-falantes permaneciam silenciosos |
| Solução | Script automático executado no início da sessão |

---

# Contribuindo

Contribuições são bem-vindas.

Caso o script funcione em outros notebooks com codec ES8336, abra uma **Issue** ou envie um **Pull Request** contendo:

- Modelo do notebook
- Distribuição Linux utilizada
- Versão do kernel
- Resultado obtido

---

**Versão:** 1.0.0  
**Shell:** Bash 5.0+  
**Áudio:** ALSA + PipeWire + WirePlumber  
**Plataforma:** Linux Mint / Ubuntu
