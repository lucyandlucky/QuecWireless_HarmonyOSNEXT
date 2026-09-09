import { QuecInterceptorFulfilled, QuecInterceptorHandler, QuecInterceptorRejected } from './IQuecInterceptor';

export class QuecInterceptorManager<T> {
  private readonly handlers: QuecInterceptorHandler<T>[] = []
  private nextId: number = 0

  private findHandlerIndex(id: number): number {
    return this.handlers.findIndex(
      (handler: QuecInterceptorHandler<T>) => handler.id === id
    )
  }

  public use(onFulfilled: QuecInterceptorFulfilled<T>, onRejected?: QuecInterceptorRejected<T>): number {
    const id: number = this.nextId
    const handler: QuecInterceptorHandler<T> = {
      id,
      onFulfilled,
      onRejected
    }

    this.nextId += 1
    this.handlers.push(handler)
    return id
  }

  public eject(id: number): void {
    const index: number = this.findHandlerIndex(id)
    if (index < 0) {
      return
    }
    this.handlers.splice(index, 1)
  }

  public clear(): void {
    this.handlers.splice(0, this.handlers.length)
  }

  public getHandlers(): QuecInterceptorHandler<T>[] {
    return this.handlers.slice()
  }
}