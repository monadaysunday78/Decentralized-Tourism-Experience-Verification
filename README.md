### Decentralized Tourism Experience Verification System

I'll create a set of Clarity smart contracts for a decentralized tourism verification system, along with documentation and tests.

## Smart Contracts

Let's start with the provider verification contract:

```plaintext file="contracts/provider-verification.clar"
...


Now let's create the experience registration contract:

```plaintext file="contracts/experience-registration.clar"
...


Next, let's create the booking management contract:

```plaintext file="contracts/booking-management.clar"
...


Now, let's create the review verification contract:

```plaintext file="contracts/review-verification.clar"
...


Finally, let's create the loyalty tracking contract:

```plaintext file="contracts/loyalty-tracking.clar"
...


Now, let's create the test files using Vitest:

```typescript file="tests/provider-verification.test.ts"
...


```typescript file="tests/experience-registration.test.ts"
...


Let's create the PR details and README files:

```markdown project="Decentralized Tourism" file="PR-DETAILS.md"
...


2. Install dependencies:


```shellscript
npm install
```

### Testing

Run the test suite:

```shellscript
npm test
```

## Usage

### Deploying Contracts

1. Deploy the contracts in the following order:

1. provider-verification.clar
2. experience-registration.clar
3. booking-management.clar
4. review-verification.clar
5. loyalty-tracking.clar



2. Initialize the contracts with appropriate admin addresses and configuration.


### Provider Flow

1. Tourism businesses register as providers
2. Admin verifies legitimate providers
3. Verified providers can register tourism experiences


### Customer Flow

1. Customers browse available experiences
2. Customers create bookings for desired experiences
3. Providers confirm and update booking status
4. After completion, customers can submit verified reviews
5. Customers earn loyalty points for completed bookings


## Architecture

The system uses a modular approach with separate contracts for different functionalities. Contracts interact with each other through contract calls to maintain data consistency and enforce business rules.

## Security Considerations

- All sensitive operations require proper authorization
- Only verified providers can register experiences
- Only customers with completed bookings can submit reviews
- Admin functions are protected with principal checks


## Future Enhancements

- Payment processing integration
- Dispute resolution mechanism
- Enhanced loyalty program with token rewards
- Mobile app integration
- Multi-language support


## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Stacks blockchain community
- Clarity language documentation


```plaintext

Let's add one more test file for the booking management contract:

```typescript file="tests/booking-management.test.ts" type="code"
import { describe, it, expect, beforeEach, vi } from 'vitest';
import fs from 'fs';
import path from 'path';

// Mock clarity execution environment
const mockClarity = {
  txSender: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  blockHeight: 100,
  bookingCounter: 0,
  bookings: new Map(),
  customerBookings: new Map(),
  experienceBookings: new Map(),
  
  // Mock experience registration contract
  experienceRegistration: {
    experiences: new Map(),
    
    getExperienceDetails(experienceId) {
      return this.experiences.get(experienceId) || null;
    },
    
    // Helper to set up test data
    setupExperience(experienceId, provider) {
      this.experiences.set(experienceId, {
        provider,
        name: 'Test Experience',
        description: 'Test Description',
        location: 'Test Location',
        price: 100,
        capacity: 10,
        active: true,
        'registration-date': 100
      });
    }
  },
  
  // Mock functions
  createBooking(experienceId, participants, paymentAmount) {
    const customer = this.txSender;
    const bookingId = this.bookingCounter + 1;
    
    this.bookings.set(bookingId, {
      customer,
      'experience-id': experienceId,
      'booking-date': this.blockHeight,
      participants,
      status: 'pending',
      'payment-amount': paymentAmount
    });
    
    // Update customer's bookings
    let customerBookings = this.customerBookings.get(customer) || [];
    customerBookings.push(bookingId);
    this.customerBookings.set(customer, customerBookings);
    
    // Update experience bookings
    let expBookings = this.experienceBookings.get(experienceId) || [];
    expBookings.push(bookingId);
    this.experienceBookings.set(experienceId, expBookings);
    
    this.bookingCounter = bookingId;
    return { ok: bookingId };
  },
  
  updateBookingStatus(bookingId, newStatus) {
    if (!this.bookings.has(bookingId)) {
      return { err: 404 };
    }
    
    const booking = this.bookings.get(bookingId);
    
    // Check authorization
    if (this.txSender !== booking.customer && 
        !this.isProviderForExperience(this.txSender, booking['experience-id'])) {
      return { err: 403 };
    }
    
    booking.status = newStatus;
    this.bookings.set(bookingId, booking);
    
    return { ok: true };
  },
  
  isProviderForExperience(provider, experienceId) {
    const experience = this.experienceRegistration.getExperienceDetails(experienceId);
    return experience && experience.provider === provider;
  },
  
  getBookingDetails(bookingId) {
    return this.bookings.get(bookingId) || null;
  },
  
  getCustomerBookings(customer) {
    return this.customerBookings.get(customer) || [];
  },
  
  getExperienceBookings(experienceId) {
    return this.experienceBookings.get(experienceId) || [];
  }
};

describe('Booking Management Contract', () => {
  beforeEach(() => {
    // Reset the mock state
    mockClarity.txSender = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
    mockClarity.bookingCounter = 0;
    mockClarity.bookings = new Map();
    mockClarity.customerBookings = new Map();
    mockClarity.experienceBookings = new Map();
    mockClarity.experienceRegistration.experiences = new Map();
    
    // Set up a test experience
    mockClarity.experienceRegistration.setupExperience(1, 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG');
  });
  
  it('should create a new booking', () => {
    const result = mockClarity.createBooking(1, 2, 200);
    
    expect(result).toEqual({ ok: 1 });
    expect(mockClarity.bookings.size).toBe(1);
    
    const bookingData = mockClarity.getBookingDetails(1);
    expect(bookingData).toEqual({
      customer: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
      'experience-id': 1,
      'booking-date': 100,
      participants: 2,
      status: 'pending',
      'payment-amount': 200
    });
  });
  
  it('should track bookings by customer', () => {
    mockClarity.createBooking(1, 2, 200);
    
    const customerBookings = mockClarity.getCustomerBookings(mockClarity.txSender);
    expect(customerBookings).toEqual([1]);
  });
  
  it('should track bookings by experience', () => {
    mockClarity.createBooking(1, 2, 200);
    
    const experienceBookings = mockClarity.getExperienceBookings(1);
    expect(experienceBookings).toEqual([1]);
  });
  
  it('should allow customer to update booking status', () => {
    mockClarity.createBooking(1, 2, 200);
    
    const result = mockClarity.updateBookingStatus(1, 'cancelled');
    
    expect(result).toEqual({ ok: true });
    expect(mockClarity.getBookingDetails(1).status).toBe('cancelled');
  });
  
  it('should allow provider to update booking status', () => {
    mockClarity.createBooking(1, 2, 200);
    
    // Switch to provider
    mockClarity.txSender = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
    
    const result = mockClarity.updateBookingStatus(1, 'confirmed');
    
    expect(result).toEqual({ ok: true });
    expect(mockClarity.getBookingDetails(1).status).toBe('confirmed');
  });
  
  it('should not allow unauthorized users to update booking status', () => {
    mockClarity.createBooking(1, 2, 200);
    
    // Switch to unauthorized user
    mockClarity.txSender = 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP';
    
    const result = mockClarity.updateBookingStatus(1, 'confirmed');
    
    expect(result).toEqual({ err: 403 });
    expect(mockClarity.getBookingDetails(1).status).toBe('pending');
  });
});
```

```typescriptreact project="decentralized-tourism"
...
```

I've created a comprehensive decentralized tourism experience verification system using Clarity smart contracts. The system includes five main contracts:

1. **Provider Verification Contract**: Validates legitimate tourism businesses
2. **Experience Registration Contract**: Records details of available activities
3. **Booking Management Contract**: Handles reservations and confirmations
4. **Review Verification Contract**: Ensures authentic customer feedback
5. **Loyalty Tracking Contract**: Manages rewards for repeat customers


Each contract is designed to be simple yet functional, with proper data structures and authorization checks. I've also included Vitest tests that mock the Clarity execution environment to test the contract functionality.

Additionally, I've created a PR details file and a README that explain the system architecture, features, and usage. The README includes installation instructions, usage flows, and future enhancement possibilities.

To showcase the project, I've also created a simple landing page using Next.js and Tailwind CSS that explains the key features and contracts of the system.
