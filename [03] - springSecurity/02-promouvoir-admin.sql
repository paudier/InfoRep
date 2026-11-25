-- Donne le rôle ADMIN à un utilisateur déjà inscrit (adapter l'e-mail).
-- L'utilisateur doit se reconnecter ensuite.
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'annie@mail.net' AND r.name = 'ADMIN';
