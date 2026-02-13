import csv
import matplotlib.pyplot as plt

corners = []
fmax = []
edap = []

with open("results_summary.csv") as f:
    reader = csv.DictReader(f)
    for row in reader:
        corners.append(row["Corner"])
        fmax.append(float(row["Fmax(MHz)"]))
        edap.append(float(row["EDAP"]))

plt.figure()
plt.bar(corners, fmax)
plt.title("Fmax per Corner")
plt.ylabel("MHz")
plt.savefig("fmax_plot.png")

plt.figure()
plt.bar(corners, edap)
plt.title("EDAP per Corner")
plt.ylabel("EDAP")
plt.savefig("edap_plot.png")

print("Plots generated.")