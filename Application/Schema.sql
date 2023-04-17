-- Your database schema. Use the Schema Designer at http://localhost:8001/ to add some tables.
CREATE TABLE tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    description TEXT NOT NULL
);
CREATE TABLE tags (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    task_id UUID NOT NULL,
    Number INT NOT NULL
);
CREATE INDEX tags_task_id_index ON tags (task_id);
ALTER TABLE tags ADD CONSTRAINT tags_ref_task_id FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE NO ACTION;
