# rmapi
## Endpoints & URL Construction
The app interacts with the public **Rick and Morty API** to fetch character data.
* **Base URL:** `https://rickandmortyapi.com/api`
* **Endpoint:** `/character`
* **Method:** `GET`

**URL Construction:**
Instead of unsafe string concatenation, we used `URLComponents` to construct the request URLs. This ensures that query parameters are properly encoded.
* **Query Items:**
    * `page`: Integer (calculated from the current pagination state).
    * `name`: String (optional, derived from the user's search input).