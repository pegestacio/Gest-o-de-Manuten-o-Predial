# Gestão de Manutenção Predial

App em HTML único (`index.html`) com Supabase (banco, login e fotos).

## Arquivos
- `index.html` — o app (URL e chave publicável do Supabase ficam no topo do script)
- `schema.sql` — banco, regras de acesso e bucket de fotos (rodar uma vez no SQL Editor do Supabase)

## Fluxo de trabalho
```
git init
git add .
git commit -m "primeira versão"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/manutencao-predial.git
git push -u origin main
```
Depois, a cada alteração: `git add . && git commit -m "descrição" && git push`.
Ligue em GitHub → Settings → Pages (branch `main`, pasta `/ (root)`).

## Segurança
- Nunca coloque a chave `sb_secret_...` neste projeto.
- Torne-se administrador (depois de criar a conta no app):
  `update public.perfis set papel='admin' where id=(select id from auth.users where email='SEU_EMAIL');`
