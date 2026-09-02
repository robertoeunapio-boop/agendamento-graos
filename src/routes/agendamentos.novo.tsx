import { createFileRoute } from "@tanstack/react-router";
import { FormularioAgendamento } from "@/components/FormularioAgendamento";
import { Tela, TopAppBar } from "@/components/m3";

export const Route = createFileRoute("/agendamentos/novo")({
  head: () => ({
    meta: [
      { title: "Novo agendamento — Agenda de Grãos" },
      {
        name: "description",
        content:
          "Formulário para criar um agendamento de carga ou descarga de grãos com data, horário, grão e caminhão.",
      },
      { property: "og:title", content: "Novo agendamento — Agenda de Grãos" },
      {
        property: "og:description",
        content: "Crie um agendamento informando título, data, grão, caminhão e horário.",
      },
    ],
  }),
  component: Novo,
});

function Novo() {
  return (
    <Tela>
      <TopAppBar titulo="Novo agendamento" voltarPara={{ to: "/agendamentos" }} />
      <main className="flex-1">
        <FormularioAgendamento />
      </main>
    </Tela>
  );
}
