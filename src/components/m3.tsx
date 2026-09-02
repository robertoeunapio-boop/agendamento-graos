import type { ReactNode } from "react";
import { Link } from "@tanstack/react-router";

export function Tela({ children }: { children: ReactNode }) {
  return (
    <div className="mx-auto flex min-h-screen w-full max-w-md flex-col bg-background text-foreground">
      {children}
    </div>
  );
}

export function TopAppBar({
  titulo,
  voltarPara,
  acao,
}: {
  titulo: string;
  voltarPara?: { to: string; params?: Record<string, string> };
  acao?: ReactNode;
}) {
  return (
    <header className="flex items-center gap-1 bg-surface-container px-1 py-2">
      {voltarPara ? (
        <Link
          to={voltarPara.to}
          params={voltarPara.params as never}
          aria-label="Voltar"
          className="flex size-12 items-center justify-center rounded-full text-on-surface transition-colors active:bg-on-surface/10"
        >
          <svg viewBox="0 0 24 24" className="size-6" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M15 19l-7-7 7-7" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </Link>
      ) : (
        <span className="w-3" />
      )}
      <h1 className="flex-1 truncate text-title-large">{titulo}</h1>
      {acao}
    </header>
  );
}

export function Campo({
  label,
  erro,
  apoio,
  children,
}: {
  label: string;
  erro?: string | undefined;
  apoio?: string | undefined;
  children: ReactNode;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-label-large text-on-surface-variant">{label}</span>
      {children}
      {(erro || apoio) && (
        <span
          className={`mt-1 block text-body-small ${erro ? "text-error" : "text-on-surface-variant"}`}
        >
          {erro || apoio}
        </span>
      )}
    </label>
  );
}

export function inputClasses(erro?: boolean) {
  return `w-full rounded-t-md border-0 border-b-2 bg-surface-container-high px-4 py-3.5 text-body-large text-on-surface outline-none transition-colors placeholder:text-on-surface-variant focus:border-primary ${
    erro ? "border-error" : "border-outline"
  }`;
}

export function BotaoPrincipal({
  children,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      {...props}
      className="flex h-14 w-full items-center justify-center rounded-full bg-primary text-label-large text-on-primary shadow-elev-1 transition-opacity active:opacity-80 disabled:opacity-40"
    >
      {children}
    </button>
  );
}

export function BotaoTexto({
  children,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      {...props}
      className="flex h-12 items-center justify-center rounded-full px-4 text-label-large text-primary transition-colors active:bg-primary/10"
    >
      {children}
    </button>
  );
}

export function Chip({
  ativo,
  children,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { ativo?: boolean }) {
  return (
    <button
      type="button"
      {...props}
      className={`h-8 shrink-0 rounded-lg border px-3 text-label-large transition-colors ${
        ativo
          ? "border-secondary-container bg-secondary-container text-on-secondary-container"
          : "border-outline text-on-surface-variant"
      }`}
    >
      {children}
    </button>
  );
}

export function Banner({ tipo, children }: { tipo: "erro" | "sucesso"; children: ReactNode }) {
  return (
    <div
      role="status"
      className={`rounded-md px-4 py-3 text-body-medium ${
        tipo === "erro"
          ? "bg-error-container text-on-error-container"
          : "bg-secondary-container text-on-secondary-container"
      }`}
    >
      {children}
    </div>
  );
}

export function Carregando({ texto = "Carregando…" }: { texto?: string }) {
  return (
    <div className="flex flex-col items-center gap-4 px-6 py-16">
      <span className="size-10 animate-spin rounded-full border-4 border-primary/25 border-t-primary" />
      <p className="text-body-medium text-on-surface-variant">{texto}</p>
    </div>
  );
}
