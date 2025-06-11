# Heranında Tahsilat

Heranında Tahsilat, firmaların müşterilerinden kredi kartı ile online tahsilat yapabilmesini sağlayan, sanal POS destekli ve mobil uyumlu bir sistemdir.

## 🚀 Proje Amacı

Bu sistem ile firmalar:

1. Müşteri bilgilerini ve borçlarını tanımlar.
2. Otomatik olarak bir ödeme linki oluşturur ve SMS/e-posta ile müşteriye gönderir.
3. Müşteri, linke tıklayarak kredi kartı ile ödeme yapabilir.
4. Tahsilat tamamlandığında, ödeme bilgileri firma paneline yansıtılır.

---

## 🧱 Proje Teknolojileri

### Backend

- **Framework:** Laravel 12  
  [Laravel Documentation](https://laravel.com/docs/12.x)

### Kullanılan Paketler

- **Authentication:** Laravel Passport  
  [Passport Docs](https://laravel.com/docs/12.x/passport)

- **Authorization:** Spatie Laravel Permission  
  [Permission Docs](https://spatie.be/docs/laravel-permission)

- **Loglama:** Spatie Activitylog  
  [Activitylog Docs](https://spatie.be/docs/laravel-activitylog)

- **Medya Yönetimi:** Spatie Medialibrary  
  [Medialibrary Docs](https://spatie.be/docs/laravel-medialibrary)

- **Testing:** Pest PHP  
  [Pest Docs](https://pestphp.com/docs)

---

## ⚙️ Kurulum Adımları

```bash
# 1. Gerekli PHP paketlerini kur
composer install

# 2. Laravel Sail ile konteyneri başlat
./vendor/bin/sail up -d
# Sail hakkında bilgi: https://laravel.com/docs/12.x/sail

# 3. Uygulama anahtarını üret
php artisan key:generate

# 4. Passport anahtarlarını oluştur
php artisan passport:keys

# 4. Veritabanı tablolarını oluştur
php artisan migrate

# 5. Varsayılan verileri ekle
php artisan db:seed

# 6. Storage klasörü için sembolik link oluştur
php artisan storage:link

# 7. Client oluşturur.
php artisan passport:client --personal

# 7. Laravel mimarisini kontrol et (opsiyonel)
./vendor/bin/pest

# 8. Code style fix yapmak için (opsiyonel)
./vendor/bin/pint
```

## 📝 API Endpointleri

### Genel Test Endpointi

| Method | Endpoint     | Açıklama               | Auth Gerekli |
|--------|--------------|------------------------|--------------|
| GET    | /test        | Test amaçlı endpoint   | Hayır        |

### v1 - Guest (Giriş Yapmamış Kullanıcılar)

| Method | Endpoint                             | Açıklama                                 | Auth Gerekli |
|--------|--------------------------------------|------------------------------------------|--------------|
| POST   | /v1/auth/login                       | Kullanıcı girişi                         | Hayır        |
| POST   | /v1/auth/registrations/individual    | Bireysel kullanıcı kaydı                 | Hayır        |
| POST   | /v1/auth/registrations/company       | Firma kaydı                              | Hayır        |
| POST   | /v1/auth/forgot-password             | Şifre sıfırlama bağlantısı talebi        | Hayır        |
| POST   | /v1/auth/reset-password              | Şifre sıfırlama işlemi                   | Hayır        |

### v1 - Auth (Giriş Yapmış Kullanıcılar)

| Method | Endpoint                      | Açıklama                        | Auth Gerekli |
|--------|-------------------------------|---------------------------------|--------------|
| POST   | /v1/auth/logout               | Kullanıcı çıkışı                | Evet         |

#### Kaynaklar (Resources)

| Method    | Endpoint         | Açıklama             | Auth Gerekli |
|-----------|------------------|----------------------|--------------|
| GET       | /v1/roles        | Roller listesi       | Evet         |
| POST      | /v1/roles        | Yeni rol oluştur     | Evet         |
| GET       | /v1/roles/{id}   | Rol detayı           | Evet         |
| PUT/PATCH | /v1/roles/{id}   | Rol güncelle         | Evet         |
| DELETE    | /v1/roles/{id}   | Rol sil              | Evet         |

| Method    | Endpoint           | Açıklama             | Auth Gerekli |
|-----------|--------------------|----------------------|--------------|
| GET       | /v1/modules        | Modül listesi        | Evet         |
| POST      | /v1/modules        | Yeni modül oluştur   | Evet         |
| GET       | /v1/modules/{id}   | Modül detayı         | Evet         |
| PUT/PATCH | /v1/modules/{id}   | Modül güncelle       | Evet         |
| DELETE    | /v1/modules/{id}   | Modül sil            | Evet         |

| Method    | Endpoint             | Açıklama               | Auth Gerekli |
|-----------|----------------------|------------------------|--------------|
| GET       | /v1/customers        | Müşteri listesi        | Evet         |
| POST      | /v1/customers        | Yeni müşteri ekle      | Evet         |
| GET       | /v1/customers/{id}   | Müşteri detayı         | Evet         |
| PUT/PATCH | /v1/customers/{id}   | Müşteri güncelle       | Evet         |
| DELETE    | /v1/customers/{id}   | Müşteri sil            | Evet         |

| Method    | Endpoint          | Açıklama           | Auth Gerekli |
|-----------|-------------------|--------------------|--------------|
| GET       | /v1/debts         | Borç listesi       | Evet         |
| POST      | /v1/debts         | Yeni borç ekle     | Evet         |
| GET       | /v1/debts/{id}    | Borç detayı        | Evet         |
| PUT/PATCH | /v1/debts/{id}    | Borç güncelle      | Evet         |
| DELETE    | /v1/debts/{id}    | Borç sil           | Evet         |

#### KYC (Kimlik Doğrulama Belgeleri)

| Method | Endpoint                                 | Açıklama                         | Auth Gerekli |
|--------|------------------------------------------|----------------------------------|--------------|
| GET    | /v1/users/{user}/kyc                     | Kullanıcının KYC belgeleri       | Evet         |
| POST   | /v1/users/{user}/kyc                     | KYC belgesi yükle                | Evet         |
| PATCH  | /v1/users/{user}/kyc/{kycDocument}       | KYC belgesi doğrula              | Evet         |
