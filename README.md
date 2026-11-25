# 🌤️ Aplikasi Cuaca — Responsi Flutter

Aplikasi cuaca berbasis Flutter yang menampilkan informasi cuaca real-time menggunakan **Open-Meteo API**, dibangun dengan arsitektur **MVVM (Model-View-ViewModel)** dan state management **Provider**.

---

## 📸 Screenshots

<img width="432" height="886" alt="image" src="https://github.com/user-attachments/assets/38ade8ac-d749-4152-b2b8-7765bf8d42e6" />
<img width="432" height="886" alt="image" src="https://github.com/user-attachments/assets/4d7e51de-4713-40af-9a69-eb13cb998d47" />




---

## 📁 Struktur Aplikasi

```
lib/
├── main.dart                        # Entry point, inisialisasi Provider & MaterialApp
│
├── models/                          # [M] Layer Model (MVVM)
│   ├── weather_model.dart           # Model data cuaca: CurrentWeather, DailyWeather, WeatherModel
│   └── location_model.dart          # Model data lokasi hasil Geocoding API
│
├── services/                        # Layer Service / Repository
│   ├── weather_service.dart         # HTTP request ke Open-Meteo Weather & Geocoding API
│   └── local_storage_service.dart   # Persistensi data via SharedPreferences
│
├── viewmodels/                      # [VM] Layer ViewModel (MVVM)
│   ├── weather_viewmodel.dart       # State cuaca: loading/loaded/error, favorit, lokasi aktif
│   └── search_viewmodel.dart        # State pencarian: live search, riwayat, daftar favorit
│
├── views/                           # [V] Layer View (MVVM)
│   ├── home_screen.dart             # Home / Weather Screen
│   └── search_screen.dart          # Search / Location Screen
│
└── utils/
    └── weather_helper.dart          # Helper: konversi kode cuaca WMO → teks & emoji
```

---

## 🏗️ Penerapan Arsitektur MVVM

Aplikasi mengikuti pola **Model-View-ViewModel** secara ketat:

```
┌─────────────────────────────────────────────────────────────┐
│                        VIEW LAYER                           │
│  home_screen.dart          search_screen.dart               │
│  - Render UI                - Render UI                     │
│  - Listen ke ViewModel      - Listen ke ViewModel           │
│  - Tidak ada logika bisnis  - Tidak ada logika bisnis       │
└──────────────────┬──────────────────────┬───────────────────┘
                   │ Consumer / context    │
                   │ .read<ViewModel>()    │
┌──────────────────▼──────────────────────▼───────────────────┐
│                     VIEWMODEL LAYER                         │
│  WeatherViewModel              SearchViewModel              │
│  - Menyimpan state cuaca       - Menyimpan state search     │
│  - Memanggil WeatherService    - Memanggil WeatherService   │
│  - notifyListeners() saat      - Mengelola riwayat &        │
│    state berubah               favorit via LocalStorage     │
└──────────────────┬──────────────────────────────────────────┘
                   │ depends on
┌──────────────────▼──────────────────────────────────────────┐
│                      MODEL + SERVICE LAYER                  │
│  WeatherService              LocalStorageService            │
│  - HTTP GET ke Open-Meteo    - SharedPreferences            │
│  - Parse JSON → Model        - Simpan/baca favorit          │
│                              - Simpan/baca riwayat          │
│  WeatherModel / LocationModel                               │
│  - Pure data class (fromJson)                               │
└─────────────────────────────────────────────────────────────┘
```

### Alur Data
1. **View** memanggil method di **ViewModel** (misal: `selectLocation(loc)`)
2. **ViewModel** memanggil **Service** untuk fetch data dari API
3. **Service** melakukan HTTP GET, parse JSON → **Model**
4. **ViewModel** menyimpan hasil di state, lalu `notifyListeners()`
5. **View** di-rebuild otomatis melalui `Consumer<ViewModel>`

---

## 🌐 Implementasi API Open-Meteo

### 1. Geocoding API — Pencarian Kota

**Endpoint:**
```
GET https://geocoding-api.open-meteo.com/v1/search
```

**Parameter:**
| Parameter | Nilai | Keterangan |
|-----------|-------|-----------|
| `name` | `{query}` | Nama kota yang dicari |
| `count` | `10` | Jumlah hasil maksimum |
| `language` | `id` | Bahasa Indonesia |
| `format` | `json` | Format respons |

**Contoh Request:**
```
GET https://geocoding-api.open-meteo.com/v1/search?name=Jakarta&count=10&language=id&format=json
```

**Contoh Respons:**
```json
{
  "results": [
    {
      "id": 1642911,
      "name": "Jakarta",
      "latitude": -6.21462,
      "longitude": 106.84513,
      "country": "Indonesia",
      "admin1": "Jakarta"
    }
  ]
}
```

---

### 2. Weather Forecast API — Data Cuaca

**Endpoint:**
```
GET https://api.open-meteo.com/v1/forecast
```

**Parameter:**
| Parameter | Nilai | Keterangan |
|-----------|-------|-----------|
| `latitude` | `{lat}` | Koordinat lintang lokasi |
| `longitude` | `{lon}` | Koordinat bujur lokasi |
| `current` | *(lihat di bawah)* | Data cuaca terkini |
| `daily` | *(lihat di bawah)* | Prakiraan cuaca harian |
| `timezone` | `auto` | Zona waktu otomatis |
| `forecast_days` | `7` | 7 hari ke depan |

**Field `current` yang diminta:**
```
temperature_2m, relative_humidity_2m, apparent_temperature,
precipitation, weather_code, wind_speed_10m
```

**Field `daily` yang diminta:**
```
temperature_2m_max, temperature_2m_min,
precipitation_probability_max, weather_code
```

**Contoh Request:**
```
GET https://api.open-meteo.com/v1/forecast?latitude=-6.21462&longitude=106.84513
    &current=temperature_2m,relative_humidity_2m,apparent_temperature,
              precipitation,weather_code,wind_speed_10m
    &daily=temperature_2m_max,temperature_2m_min,
           precipitation_probability_max,weather_code
    &timezone=auto&forecast_days=7
```

**Data yang Ditampilkan:**
| Data | Field API | Tampil di |
|------|-----------|-----------|
| Suhu saat ini | `current.temperature_2m` | Suhu besar di tengah |
| Kelembapan | `current.relative_humidity_2m` | Info tile |
| Suhu dirasakan | `current.apparent_temperature` | Subtitle & info tile |
| Curah hujan | `current.precipitation` | Info tile |
| Kode cuaca | `current.weather_code` | Emoji & deskripsi cuaca |
| Kecepatan angin | `current.wind_speed_10m` | Info tile |
| Suhu maks harian | `daily.temperature_2m_max` | Prakiraan 7 hari |
| Suhu min harian | `daily.temperature_2m_min` | Prakiraan 7 hari |
| Peluang hujan | `daily.precipitation_probability_max` | Prakiraan 7 hari |

---

## 📦 Dependensi

| Package | Versi | Fungsi |
|---------|-------|--------|
| `provider` | ^6.1.2 | State management (ChangeNotifier) |
| `http` | ^1.2.2 | HTTP request ke Open-Meteo API |
| `shared_preferences` | ^2.3.3 | Local storage favorit & riwayat |
| `intl` | ^0.19.0 | Format tanggal prakiraan (Bahasa Indonesia) |

---


## 🚀 Cara Menjalankan

```bash
# 1. Install dependencies
flutter pub get

# 2. Jalankan aplikasi (pastikan emulator/device aktif)
flutter run


```
---

