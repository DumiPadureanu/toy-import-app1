/**
 * Simple in-memory cache implementation
 * For production, use Redis or similar
 */
class Cache {
  constructor() {
    this.store = new Map();
    this.expiry = new Map();
  }

  /**
   * Set value in cache with optional TTL (in seconds)
   */
  set(key, value, ttl = 3600) {
    this.store.set(key, value);
    if (ttl > 0) {
      const expiryTime = Date.now() + (ttl * 1000);
      this.expiry.set(key, expiryTime);
      
      // Auto-cleanup
      setTimeout(() => this.delete(key), ttl * 1000);
    }
  }

  /**
   * Get value from cache
   */
  get(key) {
    if (!this.store.has(key)) {
      return null;
    }

    // Check if expired
    const expiryTime = this.expiry.get(key);
    if (expiryTime && Date.now() > expiryTime) {
      this.delete(key);
      return null;
    }

    return this.store.get(key);
  }

  /**
   * Delete value from cache
   */
  delete(key) {
    this.store.delete(key);
    this.expiry.delete(key);
  }

  /**
   * Clear entire cache
   */
  clear() {
    this.store.clear();
    this.expiry.clear();
  }

  /**
   * Check if key exists
   */
  has(key) {
    return this.store.has(key) && this.get(key) !== null;
  }
}

// Singleton instance
const cache = new Cache();

module.exports = cache;
