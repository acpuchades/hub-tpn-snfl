library(readxl)
library(haven)
library(tidyverse)
library(writexl)

data <- read_excel("data/Resultados NFL_Roser Velasco.xlsx") |>
    select(
        id_muestra = "Código muestra",
        concentracion = "Concentración media NFL (pg/mL)"
    ) |>
    separate_wider_regex(
        id_muestra,
        patterns = c(
            id_paciente = "-?\\d+",
            "_",
            fecha_muestra = "\\d{2}-\\d{2}-\\d{4}"
        )
    ) |>
    mutate(
        fecha_muestra = dmy(fecha_muestra)
    ) |>
    group_by(id_paciente) |>
    arrange(fecha_muestra, .by_group = TRUE) |>
    mutate(
        id_intrapaciente = row_number()
    ) |>
    ungroup()

datos_fechas <- data |>
    select(id_paciente, id_intrapaciente, fecha_muestra) |>
    pivot_wider(
        names_from = id_intrapaciente,
        names_prefix = "fecha_",
        values_from = fecha_muestra
    )

datos_concentracion <- data |>
    select(id_paciente, id_intrapaciente, concentracion) |>
    pivot_wider(
        names_from = id_intrapaciente,
        names_prefix = "concentracion_",
        values_from = concentracion
    )

resultados <- datos_fechas |>
    left_join(datos_concentracion, by = "id_paciente") |>
    relocate

dir.create("output", showWarnings = FALSE)
write_sav(resultados, "output/resultados.sav")
write_xlsx(resultados, "output/resultados.xlsx")
