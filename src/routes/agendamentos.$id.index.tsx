import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Banner, BotaoTexto, Carregando, Tela, TopAppBar } from "@/components/m3";
import {
  excluirAgendamento,
  formatarData,
  formatarHorario,
  obterAgendamento,
  rotulosCaminhao,
  rotulosGrao,
  rotulosTipo,
  type Agendamento,
} from "@/lib/mock";

export const Route = createFileRoute("/agendamentos/$id/")({
  head: () => ({
    meta: [
      { title: "Detalhe do agendamento — Agenda de Grãos" },
      {
        name: "description",
        content:
          "Detalhes do agendamento de grãos com opções de editar e excluir com confirmação.",
      },
      { property: "og:title", content: "Detalhe do agendamento — Agenda de Grãos" },
      {
        property: "og:description",
        content: "Veja data, horário, grão, caminhão, observação e motoristas do agendamento.",
      },
    ],
  }),
  component: Detalhe,
});

function Linha({ rotulo, valor }: { rotulo: string; valor: string }) {
  return (
    <div className="flex items-start justify-between gap-4 border-b border-outline-variant py-3">
      <span className="text-body-medium text-on-surface-variant">{rotulo}</span>
      <span className="text-right text-body-large">{valor}</span>
    </div>
  );
}

function Detalhe() {
  const { id } = Route.useParams();
  const navigate = useNavigate();
  const [estado, setEstado] = useState<"carregando" | "ok" | "vazio" | "excluindo">("carregando");
  const [item, setItem] = useState<Agendamento | undefined>();
  const [confirmar, setConfirmar] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => {
      const encontrado = obterAgendamento(id);
      setItem(encontrado);
      setEstado(encontrado ? "ok" : "vazio");
    }, 600);
    return () => clearTimeout(t);
  }, [id]);

  function excluir() {
    setConfirmar(false);
    setEstado("excluindo");
    setTimeout(() => {
      excluirAgendamento(id);
      navigate({ to: "/agendamentos" });
    }, 800);
  }

  return (
    <Tela>
      <TopAppBar titulo="Agendamento" voltarPara={{ to: "/agendamentos" }} />
      <main className="flex-1 px-4 pb-10">
        {estado === "carregando" ? <Carregando texto="Carregando agendamento…" /> : null}
        {estado === "excluindo" ? <Carregando texto="Excluindo agendamento…" /> : null}

        {estado === "vazio" ? (
          <div className="flex flex-col gap-4 pt-4">
            <Banner tipo="erro">Agendamento não encontrado ou já excluído.</Banner>
            <Link
              to="/agendamentos"
              className="flex h-12 items-center justify-center rounded-full border border-outline text-label-large text-primary"
            >
              Voltar para a lista
            </Link>
          </div>
        ) : null}

        {estado === "ok" && item ? (
          <>
            <div className="pt-2">
              <span className="inline-block rounded-lg bg-tertiary-container px-2 py-0.5 text-body-small text-on-tertiary-container">
                {rotulosTipo[item.agendamento]}
              </span>
              <h2 className="mt-3 text-headline-small">{item.titulo}</h2>
            </div>

            <div className="mt-6 rounded-lg bg-surface-container px-4 py-1">
              <Linha rotulo="Data" valor={formatarData(item.data)} />
              <Linha rotulo="Horário" valor={formatarHorario(item.horario)} />
              <Linha rotulo="Grão" valor={rotulosGrao[item.grao]} />
              <Linha rotulo="Caminhão" valor={rotulosCaminhao[item.caminhao]} />
              <Linha rotulo="Motoristas" valor={item.usuarios.join(", ")} />
            </div>

            <div className="mt-6">
              <p className="text-label-large text-on-surface-variant">Observação</p>
              <p className="mt-1 text-body-large">
                {item.observacao ?? "Nenhuma observação registrada."}
              </p>
            </div>

            <div className="mt-10 flex flex-col gap-2">
              <Link
                to="/agendamentos/$id/editar"
                params={{ id }}
                className="flex h-14 items-center justify-center rounded-full bg-primary text-label-large text-on-primary shadow-elev-1"
              >
                Editar agendamento
              </Link>
              <button
                onClick={() => setConfirmar(true)}
                className="flex h-14 items-center justify-center rounded-full border border-error text-label-large text-error active:bg-error/10"
              >
                Excluir agendamento
              </button>
            </div>
          </>
        ) : null}
      </main>

      {confirmar ? (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-scrim px-6">
          <div className="w-full max-w-sm rounded-xl bg-surface-container-high p-6 shadow-elev-3">
            <h3 className="text-headline-small">Excluir agendamento?</h3>
            <p className="mt-3 text-body-medium text-on-surface-variant">
              Esta ação não pode ser desfeita. O agendamento será removido da sua agenda.
            </p>
            <div className="mt-6 flex justify-end gap-2">
              <BotaoTexto onClick={() => setConfirmar(false)}>Cancelar</BotaoTexto>
              <button
                onClick={excluir}
                className="h-12 rounded-full px-4 text-label-large text-error active:bg-error/10"
              >
                Excluir
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </Tela>
  );
}
