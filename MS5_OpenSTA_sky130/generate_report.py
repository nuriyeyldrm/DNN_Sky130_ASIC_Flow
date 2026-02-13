import csv

with open("results_summary.csv") as f:
    reader = list(csv.reader(f))

header = reader[0]
rows = reader[1:]

with open("MS5_Report.md","w") as f:
    f.write("# MS5 Sky130 Multi-Corner Analysis\n\n")
    f.write("| " + " | ".join(header) + " |\n")
    f.write("|" + " --- |"*len(header) + "\n")

    for row in rows:
        f.write("| " + " | ".join(row) + " |\n")

print("Markdown report generated: MS5_Report.md")