import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import { Banner, Carregando, Chip, Tela, TopAppBar, inputClasses } from "@/components/m3";
import {
  esvaziarLista,
  formatarData,
  formatarHorario,
  listarAgendamentos,
  rotulosCaminhao,
  rotulosGrao,
  rotulosTipo,
  type Grao,
  type TipoAgendamento,
} from "@/lib/mock";

export const Route = createFileRoute("/agendamentos/")({
  head: () => ({
    meta: [
      { title: "Meus agendamentos — Agenda de Grãos" },
      {
        name: "description",
        content:
          "Lista de agendamentos de carregamento e descarregamento de grãos, com busca por título, data, grão e horário.",
      },
      { property: "og:title", content: "Meus agendamentos — Agenda de Grãos" },
      {
        property: "og:description",
        content: "Veja, busque e crie agendamentos de carga e descarga de grãos.",
      },
    ],
  }),
  component: Listagem,
});

const graos: Grao[] = ["sorgo", "milho", "soja"];
const tipos: TipoAgendamento[] = ["carregamento", "descarregamento"];

function Listagem() {
  const [estado, setEstado] = useState<"carregando" | "ok" | "erro">("carregando");
  const [versao, setVersao] = useState(0);
  const [busca, setBusca] = useState("");
  const [data, setData] = useState("");
  const [grao, setGrao] = useState<Grao | "">("");
  const [tipo, setTipo] = useState<TipoAgendamento | "">("");
  const [horario, setHorario] = useState("");

  useEffect(() => {
    setEstado("carregando");
    const t = setTimeout(() => setEstado("ok"), 700);
    return () => clearTimeout(t);
  }, [versao]);

  const itens = useMemo(() => {
    if (estado !== "ok") return [];
    return listarAgendamentos()
      .filter((a) => a.titulo.toLowerCase().includes(busca.trim().toLowerCase()))
      .filter((a) => (data ? a.data === data : true))
      .filter((a) => (grao ? a.grao === grao : true))
      .filter((a) => (tipo ? a.agendamento === tipo : true))
      .filter((a) => (horario ? a.horario === horario : true))
      .sort((a, b) => (a.data + a.horario).localeCompare(b.data + b.horario));
  }, [estado, versao, busca, data, grao, tipo, horario]);

  const totalBruto = estado === "ok" ? listarAgendamentos().length : 0;
  const temFiltro = !!(busca || data || grao || tipo || horario);

  function limparFiltros() {
    setBusca("");
    setData("");
    setGrao("");
    setTipo("");
    setHorario("");
  }

  return (
    <Tela>
      <TopAppBar
        titulo="Meus agendamentos"
        acao={
          <Link
            to="/"
            aria-label="Sair"
            className="mr-1 flex size-12 items-center justify-center rounded-full text-on-surface-variant active:bg-on-surface/10"
          >
            <svg viewBox="0 0 24 24" className="size-6" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M15 12H4m0 0l3-3m-3 3l3 3M12 4h6a2 2 0 012 2v12a2 2 0 01-2 2h-6" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </Link>
        }
      />

      <div className="flex flex-col gap-3 px-4 pb-4 pt-2">
        <input
          value={busca}
          onChange={(e) => setBusca(e.target.value)}
          placeholder="Buscar por título"
          className="w-full rounded-full bg-surface-container-high px-5 py-3.5 text-body-large text-on-surface outline-none placeholder:text-on-surface-variant"
        />
        <div className="flex gap-3">
          <label className="flex-1">
            <span className="mb-1 block text-body-small text-on-surface-variant">Data</span>
            <input
              type="date"
              value={data}
              onChange={(e) => setData(e.target.value)}
              className={inputClasses()}
            />
          </label>
          <label className="w-40">
            <span className="mb-1 block text-body-small text-on-surface-variant">Horário</span>
            <input
              type="time"
              value={horario}
              onChange={(e) => setHorario(e.target.value)}
              placeholder="00:00"
              className={inputClasses()}
            />
          </label>
        </div>
        <div className="flex gap-2 overflow-x-auto pb-1">
          <Chip ativo={grao === ""} onClick={() => setGrao("")}>
            Todos os grãos
          </Chip>
          {graos.map((g) => (
            <Chip key={g} ativo={grao === g} onClick={() => setGrao(g)}>
              {rotulosGrao[g]}
            </Chip>
          ))}
        </div>
        <div className="flex gap-2 overflow-x-auto pb-1">
          <Chip ativo={tipo === ""} onClick={() => setTipo("")}>
            Todos os tipos
          </Chip>
          {tipos.map((t) => (
            <Chip key={t} ativo={tipo === t} onClick={() => setTipo(t)}>
              {rotulosTipo[t]}
            </Chip>
          ))}
        </div>
      </div>

      <main className="flex-1 px-4 pb-32">
        {estado === "carregando" ? <Carregando texto="Buscando seus agendamentos…" /> : null}

        {estado === "erro" ? (
          <div className="flex flex-col gap-4">
            <Banner tipo="erro">Não foi possível carregar os agendamentos.</Banner>
            <button
              onClick={() => setVersao((v) => v + 1)}
              className="h-12 self-start rounded-full border border-outline px-6 text-label-large text-primary"
            >
              Tentar novamente
            </button>
          </div>
        ) : null}

        {estado === "ok" && itens.length === 0 ? (
          <div className="flex flex-col items-center gap-4 px-6 py-16 text-center">
            <div className="flex size-16 items-center justify-center rounded-full bg-surface-container-high text-on-surface-variant">
              <svg viewBox="0 0 24 24" className="size-8" fill="none" stroke="currentColor" strokeWidth="1.7">
                <path d="M7 3v3M17 3v3M4 8h16M5 6h14a1 1 0 011 1v13a1 1 0 01-1 1H5a1 1 0 01-1-1V7a1 1 0 011-1z" strokeLinecap="round" />
              </svg>
            </div>
            {totalBruto === 0 || !temFiltro ? (
              <>
                <h2 className="text-title-large">Nenhum agendamento ainda</h2>
                <p className="text-body-medium text-on-surface-variant">
                  Crie seu primeiro agendamento de carregamento ou descarregamento e organize suas
                  viagens.
                </p>
                <Link
                  to="/agendamentos/novo"
                  className="mt-2 flex h-12 items-center rounded-full bg-primary px-6 text-label-large text-on-primary"
                >
                  Criar primeiro agendamento
                </Link>
              </>
            ) : (
              <>
                <h2 className="text-title-large">Nada encontrado</h2>
                <p className="text-body-medium text-on-surface-variant">
                  Nenhum agendamento corresponde aos filtros aplicados.
                </p>
                <button
                  onClick={limparFiltros}
                  className="mt-2 h-12 rounded-full border border-outline px-6 text-label-large text-primary"
                >
                  Limpar filtros
                </button>
              </>
            )}
          </div>
        ) : null}

        {estado === "ok" && itens.length > 0 ? (
          <ul className="flex flex-col gap-3">
            {itens.map((a) => (
              <li key={a.id}>
                <Link
                  to="/agendamentos/$id"
                  params={{ id: a.id }}
                  className="block rounded-lg bg-surface-container p-4 active:bg-surface-container-high"
                >
                  <div className="flex items-start justify-between gap-3">
                    <h3 className="text-title-medium">{a.titulo}</h3>
                    <span className="shrink-0 rounded-lg bg-tertiary-container px-2 py-0.5 text-body-small text-on-tertiary-container">
                      {rotulosTipo[a.agendamento]}
                    </span>
                  </div>
                  <p className="mt-2 text-body-medium text-on-surface-variant">
                    {formatarData(a.data)} · {formatarHorario(a.horario)}
                  </p>
                  <p className="mt-1 text-body-medium text-on-surface-variant">
                    {rotulosGrao[a.grao]} · {rotulosCaminhao[a.caminhao]}
                  </p>
                </Link>
              </li>
            ))}
          </ul>
        ) : null}

        {estado === "ok" ? (
          <div className="mt-8 flex flex-col gap-2 border-t border-outline-variant pt-4">
            <p className="text-body-small text-on-surface-variant">Demonstração de estados:</p>
            <div className="flex flex-wrap gap-2">
              <Chip onClick={() => setEstado("carregando")}>Ver carregando</Chip>
              <Chip onClick={() => setEstado("erro")}>Ver erro</Chip>
              <Chip
                onClick={() => {
                  esvaziarLista();
                  limparFiltros();
                  setVersao((v) => v + 1);
                }}
              >
                Ver lista vazia
              </Chip>
            </div>
          </div>
        ) : null}
      </main>

      <div className="px-4 pb-6">
        <Link
          to="/agendamentos/novo"
          className="flex h-16 items-center justify-center gap-2 rounded-xl bg-primary text-label-large text-on-primary shadow-elev-3"
        >
          <svg viewBox="0 0 24 24" className="size-6" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M12 5v14M5 12h14" strokeLinecap="round" />
          </svg>
          Novo agendamento
        </Link>
      </div>
    </Tela>
  );
}
