/*
@Autor: Tiago Gadotti
@Data: 29/06/2023
@Descrição: Essa função recebe o nome da table como parâmetro(char), e monta um insert com os nomes das colunas, em posição vertical, valores defaults para os campos:
- Numéricos: 0
- Char: ''
- Date: current_date
- Timestamp: now()
Se a coluna tiver SEQUENCE, o valor default será o nextval.
Se a coluna for NOT NULL, seu nome será marcado com dois asteriscos **.
*/
CREATE OR REPLACE FUNCTION public._insert(p_table_name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
	r RECORD;
	retorno TEXT := 'INSERT INTO ' || p_table_name || E'(\n';
	primeiro_loop_colunas boolean := TRUE;
	primeiro_loop_data_type boolean := TRUE;
	concatenador varchar(1) := '';
	nome_coluna TEXT;
	contador int := 0;
	
BEGIN
	FOR r IN (SELECT column_name FROM information_schema."columns"
				WHERE table_name = p_table_name
				ORDER BY is_nullable,ordinal_position
	)
	LOOP
		IF primeiro_loop_colunas THEN
			primeiro_loop_colunas := FALSE;
			concatenador := '';
		ELSE
			concatenador := ',';
		END IF;
		retorno := retorno || concatenador || r.column_name;
		contador := contador + 1;
	
		IF contador = 10 THEN
			retorno := retorno || E'\n';
			contador := 0;
		END IF ;
	END LOOP;
	retorno := retorno || E') VALUES(\n';
	FOR r IN (SELECT data_type, column_name, is_nullable, c.column_default  
				FROM information_schema."columns" c 
				WHERE table_name = p_table_name
				ORDER BY is_nullable,ordinal_position
			)
	LOOP
		IF primeiro_loop_data_type THEN
			primeiro_loop_data_type := FALSE;
			concatenador := '';
		ELSE
			concatenador := ',';
		END IF;
		IF r.data_type IN ('bigint', 'bigserial', 'smallint', 'smallintserial', 'serial', 'numeric', 'integer') THEN
			IF r.column_default LIKE 'nextval%' THEN
				retorno := retorno || concatenador || 'SELECT ' || r.column_default || ';';
			ELSE
				retorno := retorno || concatenador || '0';
			END IF;
		END IF;
		IF r.data_type IN ('character', 'character varying', 'text') THEN 
			retorno := retorno || concatenador || '''' || '''';  -- replaced the '''' with double single quotes
		END IF;
		IF r.data_type IN ('timestamp', 'timestamp with time zone', 'timestamp without time zone') THEN 
			retorno := retorno || concatenador || 'now()';
		END IF;
		IF r.data_type IN ('date') THEN 
			retorno := retorno || concatenador || 'current_date';
		END IF;
		IF r.data_type IN ('boolean') THEN 
			retorno := retorno || concatenador || 'FALSE';
		END IF;
	
		nome_coluna := r.column_name;
		IF r.is_nullable = 'NO' THEN
			nome_coluna := nome_coluna || '**';
		END IF;
	
		retorno := retorno || '  --' || nome_coluna;
		retorno := retorno || E'\n';
	END LOOP;
	retorno := retorno || ');';
	RETURN retorno;
END;
$function$
;
