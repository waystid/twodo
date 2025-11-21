import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { coupleApi } from '../lib/couple-api';
import type { CreateCoupleInput } from '@twodo/shared';

export function CreateCouplePage() {
  const [coupleName, setCoupleName] = useState<string>('');
  const [error, setError] = useState<string>('');

  const createMutation = useMutation({
    mutationFn: (data: CreateCoupleInput) => coupleApi.createCouple(data),
    onSuccess: () => {
      // Redirect to home
      window.location.href = '/';
    },
    onError: (err: any) => {
      setError(err.message || 'Failed to create couple');
    },
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    await createMutation.mutateAsync({ name: coupleName });
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Create Your Couple</h1>
          <p className="text-gray-600">
            Give your shared space a name. You can invite your partner after creating it.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-8 space-y-6">
          {error && (
            <div className="rounded-md bg-red-50 p-4">
              <div className="text-sm text-red-700">{error}</div>
            </div>
          )}

          <div>
            <label htmlFor="coupleName" className="block text-sm font-medium text-gray-700 mb-2">
              Couple Name
            </label>
            <input
              id="coupleName"
              name="coupleName"
              type="text"
              required
              placeholder="e.g., The Smiths, Alex & Sam"
              className="appearance-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
              value={coupleName}
              onChange={(e) => setCoupleName(e.target.value)}
            />
          </div>

          <div className="flex space-x-4">
            <button
              type="button"
              onClick={() => (window.location.href = '/')}
              className="flex-1 py-2 px-4 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending}
              className="flex-1 py-2 px-4 border border-transparent rounded-md text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {createMutation.isPending ? 'Creating...' : 'Create Couple'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
