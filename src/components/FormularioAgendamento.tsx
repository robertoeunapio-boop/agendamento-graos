import { useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { Banner, BotaoPrincipal, BotaoTexto, Campo, Chip, inputClasses } from "@/components/m3";
import {
  rotulosCaminhao,
  rotulosGrao,
  rotulosTipo,
  salvarAgendamento,
  type Agendamento,
  type Caminhao,
  type Grao,
  type TipoAgendamento,
} from "@/lib/mock";

const tipos: TipoAgendamento[] = ["carregamento", "descarregamento"];
const graos: Grao[] = ["sorgo", "milho", "soja"];
const caminhoes: Caminhao[] = ["graneleiro", "cacamba"];

export function FormularioAgendamento({ inicial }: { inicial?: Agendamento }) {
  const navigate = useNavigate();
  const [titulo, setTitulo] = useState(inicial?.titulo ?? "");
  const [tipo, setTipo] = useState<TipoAgendamento>(inicial?.agendamento ?? "carregamento");
  const [data, setData] = useState(inicial?.data ?? "");
  const [grao, setGrao] = useState<Grao>(inicial?.grao ?? "soja");
  const [caminhao, setCaminhao] = useState<Caminhao>(inicial?.caminhao ?? "graneleiro");
  const [horario, setHorario] = useState(inicial?.horario ?? "");
  const [observacao, setObservacao] = useState(inicial?.observacao ?? "");
  const [erros, setErros] = useState<{ titulo?: string; data?: string; horario?: string; observacao?: string }>({});
  const [estado, setEstado] = useState<"parado" | "salvando" | "sucesso" | "erro">("parado");

  function enviar(e: React.FormEvent) {
    e.preventDefault();
    const novos: { titulo?: string; data?: string; horario?: string; observacao?: string } = {};
    if (!titulo.trim()) novos.titulo = "O título é obrigatório.";
    else if (titulo.trim().length > 80) novos.titulo = "Use no máximo 80 caracteres.";
    if (!data) novos.data = "A data é obrigatória.";
    const horaValida = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/.test(horario);
    if (horario === "") novos.horario = "O horário é obrigatório.";
    else if (!horaValida) novos.horario = "Informe o horário no formato 00:00.";
    if (observacao.length > 300) novos.observacao = "Use no máximo 300 caracteres.";
    setErros(novos);
    if (Object.keys(novos).length > 0) {
      setEstado("erro");
      return;
    }
    setEstado("salvando");
    setTimeout(() => {
      const id = salvarAgendamento({
        id: inicial?.id,
        titulo: titulo.trim(),
        agendamento: tipo,
        data,
        grao,
        caminhao,
        horario: horario.trim(),
        observacao: observacao.trim() || undefined,
      });
      setEstado("sucesso");
      setTimeout(() => navigate({ to: "/agendamentos/$id", params: { id } }), 800);
    }, 900);
  }

  return (
    <form onSubmit={enviar} className="flex flex-col gap-5 px-4 pb-12 pt-2" noValidate>
      {estado === "erro" ? (
        <Banner tipo="erro">Corrija os campos destacados para salvar.</Banner>
      ) : null}
      {estado === "sucesso" ? (
        <Banner tipo="sucesso">Agendamento salvo com sucesso!</Banner>
      ) : null}

      <Campo label="Título *" erro={erros.titulo} apoio="Obrigatório. Até 80 caracteres.">
        <input
          value={titulo}
          onChange={(e) => setTitulo(e.target.value)}
          placeholder="Carga de soja - Fazenda Boa Vista"
          className={inputClasses(!!erros.titulo)}
        />
      </Campo>

      <div>
        <p className="mb-2 text-label-large text-on-surface-variant">Agendamento</p>
        <div className="flex gap-2">
          {tipos.map((t) => (
            <Chip key={t} ativo={tipo === t} onClick={() => setTipo(t)}>
              {rotulosTipo[t]}
            </Chip>
          ))}
        </div>
      </div>

      <Campo label="Data *" erro={erros.data} apoio="Obrigatória.">
        <input
          type="date"
          value={data}
          onChange={(e) => setData(e.target.value)}
          className={inputClasses(!!erros.data)}
        />
      </Campo>

      <div>
        <p className="mb-2 text-label-large text-on-surface-variant">Grão</p>
        <div className="flex gap-2">
          {graos.map((g) => (
            <Chip key={g} ativo={grao === g} onClick={() => setGrao(g)}>
              {rotulosGrao[g]}
            </Chip>
          ))}
        </div>
      </div>

      <div>
        <p className="mb-2 text-label-large text-on-surface-variant">Caminhão</p>
        <div className="flex gap-2">
          {caminhoes.map((c) => (
            <Chip key={c} ativo={caminhao === c} onClick={() => setCaminhao(c)}>
              {rotulosCaminhao[c]}
            </Chip>
          ))}
        </div>
      </div>

      <Campo
        label="Horário *"
        erro={erros.horario}
        apoio="Obrigatório. Formato 00:00, com hora e minutos."
      >
        <input
          type="time"
          value={horario}
          onChange={(e) => setHorario(e.target.value)}
          placeholder="00:00"
          className={inputClasses(!!erros.horario)}
        />
      </Campo>

      <Campo label="Observação" erro={erros.observacao} apoio="Opcional. Até 300 caracteres.">
        <textarea
          value={observacao}
          onChange={(e) => setObservacao(e.target.value)}
          rows={4}
          placeholder="Entrar pelo portão 2 com a nota fiscal impressa."
          className={inputClasses(!!erros.observacao)}
        />
      </Campo>

      <BotaoPrincipal type="submit" disabled={estado === "salvando"}>
        {estado === "salvando" ? "Salvando…" : "Salvar agendamento"}
      </BotaoPrincipal>
      <BotaoTexto type="button" onClick={() => navigate({ to: "/agendamentos" })}>
        Cancelar
      </BotaoTexto>
    </form>
  );
}
