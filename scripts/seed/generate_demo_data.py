# scripts/seed/generate_demo_data.py
# generate reproducible CSV files (store catalog and daily sales)
import csv
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)  # fixed seed → reproducibility

# Editable parameters (simple demo)
N_STORES = 10
DATE_START = date(2024, 1, 1)
DATE_END = date(2024, 6, 30)
SKUS = ["A", "B", "C"]

# Explicit price assignment per SKU (instead of using ord())
PRICE_BY_SKU = {
    "A": 10,
    "B": 12,
    "C": 14,
}

# Output paths
IMPORTS_DIR = Path("imports")
STORES_CSV = IMPORTS_DIR / "stores.csv"
SALES_CSV = IMPORTS_DIR / "sales_2024.csv"

# Approximate bounding box for Provincia de Buenos Aires (Argentina)
LAT_MIN, LAT_MAX = -40.8, -33.0
LON_MIN, LON_MAX = -63.5, -57.0

# Geographic center for quadrant classification
LAT_CENTER = (LAT_MIN + LAT_MAX) / 2
LON_CENTER = (LON_MIN + LON_MAX) / 2

def classify_region(lat: float, lon: float) -> str:
    """
    Classify a store into NE / NW / SE / SW quadrants based on latitude and longitude.
    Note:
      - Higher latitude (less negative) = more north
      - Higher longitude (less negative) = more east
    """
    if lat > LAT_CENTER:
        return "NE" if lon > LON_CENTER else "NW"
    else:
        return "SE" if lon > LON_CENTER else "SW"

def main() -> None:
    IMPORTS_DIR.mkdir(parents=True, exist_ok=True)

    # --- Store catalog ---
    stores = []
    for i in range(1, N_STORES + 1):
        lat = round(random.uniform(LAT_MIN, LAT_MAX), 6)
        lon = round(random.uniform(LON_MIN, LON_MAX), 6)
        region = classify_region(lat, lon)

        stores.append({
            "store_id": i,
            "name": f"Store {i}",
            "region": region,
            "lat": lat,
            "lon": lon,
        })

    # Write stores.csv
    with STORES_CSV.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["store_id", "name", "region", "lat", "lon"])
        writer.writeheader()
        writer.writerows(stores)


    # --- Daily sales generation ---
    sales_rows = []
    current_date = DATE_START

    while current_date <= DATE_END:
        for store in stores:
            # Basic variability by store ID
            avg_units = 5 + (store["store_id"] % 3) * 2

            for sku in SKUS:
                units = max(0, int(random.gauss(mu=avg_units, sigma=2)))
                price = PRICE_BY_SKU[sku]
                revenue = units * price

                sales_rows.append({
                    "date": current_date.isoformat(),
                    "store_id": store["store_id"],
                    "sku": sku,
                    "units": units,
                    "revenue": f"{revenue:.2f}",
                })

        current_date += timedelta(days=1)

    # Write sales_2024.csv
    with SALES_CSV.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["date", "store_id", "sku", "units", "revenue"])
        writer.writeheader()
        writer.writerows(sales_rows)

    print(f"OK: {STORES_CSV} and {SALES_CSV} generated.")
    print(f"Stores: {len(stores)} rows | Sales: {len(sales_rows)} rows")

if __name__ == "__main__":
    main()

