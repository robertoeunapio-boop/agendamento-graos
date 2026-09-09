# Regras de Negócio - Agendamento de Grãos

## RN01 - Impede Duplicidade de Agendamento
O mesmo produtor não pode cadastrar dois agendamentos ativos para o mesmo tipo de grão.

## RN02 - Busca Obrigatória
Operações de busca, alteração ou remoção exigem que o agendamento exista no acervo.

## RN03 - Proteção contra Exclusão de Concluídos
Agendamentos com status "Concluído" ou "Em Transporte" não podem ser apagados.