export type TipoAgendamento = "carregamento" | "descarregamento";
export type Grao = "sorgo" | "milho" | "soja";
export type Caminhao = "graneleiro" | "cacamba";

export type Agendamento = {
  id: string;
  titulo: string;
  agendamento: TipoAgendamento;
  data: string; // ISO yyyy-mm-dd
  grao: Grao;
  caminhao: Caminhao;
  horario: string; // HH:MM
  observacao?: string | undefined;
  usuarios: string[];
};

export const rotulosGrao: Record<Grao, string> = {
  sorgo: "Sorgo",
  milho: "Milho",
  soja: "Soja",
};

export const rotulosCaminhao: Record<Caminhao, string> = {
  graneleiro: "Graneleiro",
  cacamba: "Caçamba",
};

export const rotulosTipo: Record<TipoAgendamento, string> = {
  carregamento: "Carregamento",
  descarregamento: "Descarregamento",
};

let dados: Agendamento[] = [
  {
    id: "1",
    titulo: "Carga de soja - Fazenda Boa Vista",
    agendamento: "carregamento",
    data: "2026-09-04",
    grao: "soja",
    caminhao: "graneleiro",
    horario: "07:00",
    observacao: "Entrar pelo portão 2 com a nota fiscal impressa.",
    usuarios: ["Roberto Eunápio", "Sandra Lopes"],
  },
  {
    id: "2",
    titulo: "Descarga de milho - Armazém Central",
    agendamento: "descarregamento",
    data: "2026-09-05",
    grao: "milho",
    caminhao: "cacamba",
    horario: "14:00",
    usuarios: ["Roberto Eunápio"],
  },
  {
    id: "3",
    titulo: "Carga de sorgo - Cooperativa Sul",
    agendamento: "carregamento",
    data: "2026-09-09",
    grao: "sorgo",
    caminhao: "graneleiro",
    horario: "10:00",
    observacao: "Balança fecha às 17h.",
    usuarios: ["Roberto Eunápio", "Marcos Vieira"],
  },
];

export function listarAgendamentos() {
  return dados.slice();
}

export function obterAgendamento(id: string) {
  return dados.find((a) => a.id === id);
}

export function salvarAgendamento(
  item: Omit<Agendamento, "id" | "usuarios"> & { id?: string | undefined },
) {
  if (item.id) {
    dados = dados.map((a) => (a.id === item.id ? { ...a, ...item, id: a.id } : a));
    return item.id;
  }
  const id = String(Date.now());
  dados = [...dados, { ...item, id, usuarios: ["Roberto Eunápio"] }];
  return id;
}

export function excluirAgendamento(id: string) {
  dados = dados.filter((a) => a.id !== id);
}

export function esvaziarLista() {
  dados = [];
}

export function formatarData(iso: string) {
  const [a, m, d] = iso.split("-");
  return `${d}/${m}/${a}`;
}

export function formatarHorario(h: string) {
  return h;
}
